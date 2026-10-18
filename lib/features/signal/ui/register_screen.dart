import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/auth/session.dart';
import '../../../core/theme/tokens.g.dart';
import '../../../core/ui/ui.dart';
import '../data/local_signal_store.dart';
import '../data/server_signals.dart';
import '../data/signal_repository.dart';
import '../domain/register_candidates.dart';
import '../location/location_gate.dart';
import 'components/signal_components.dart';
import 'osm_map.dart';
import 'record_screen.dart';

/// 신호등 등록 (traffic-signal F-03, D-074).
/// 기본: ① 이름 → 첫 기록 (위치 없음 = 나만 보기). 선택: ① 이름 → ② 양 끝점 2개 → ③ "이 횡단보도인가요?" → ④ 같이 켜지는 횡단보도 → 첫 기록.
/// [locateId]가 있으면 나만 보기 신호등에 위치를 지정한다 (FR-03-A-08): ②~④ 후 공유로 바꾼다.
/// 로그인 전에는 후보가 기기에 저장한 내 횡단보도뿐이다 (FR-03-D-05)
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.locateId});
  final String? locateId;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

enum _Step { name, points, suggest, group }

/// 이름 길이 (운영 설정값 초기값, D-074)
const _nameMax = 20;

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _map = MapController();
  final _name = TextEditingController();
  final _points = <LatLng>[];
  LatLng? _me;
  late var _step = widget.locateId == null ? _Step.name : _Step.points;
  var _loading = false;
  List<Candidate> _suggestions = const [];
  List<Candidate> _members = const [];

  /// 로그인 후 내 위치 주변 공유 횡단보도 (D-070). 로그인 전에는 기기 저장소를 바로 본다
  List<Candidate> _shared = const [];

  /// 그룹 선택: 횡단보도 id, 또는 [_scrambleKey]
  String? _groupChoice;
  static const _scrambleKey = '__scramble__';

  bool get _locating => widget.locateId != null;
  String get _title => _locating ? '위치 지정' : '신호등 등록';

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    if (_locating) WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// 위치 지정을 고른 경우에만 현재 위치를 쓴다 (D-074). 기본 등록은 GPS 없이
  Future<void> _locate() async {
    final pos = await ensureLocation(context, action: '위치 지정', needAccuracy: true);
    if (!mounted) return;
    if (pos == null) {
      if (_locating) return context.pop();
      return setState(() => _step = _Step.name);
    }
    setState(() => _me = LatLng(pos.latitude, pos.longitude));
    _map.move(_me!, 19);
    if (ref.read(sessionProvider).loggedIn) {
      final list = await _sharedAround(_me!, existingRadiusM);
      if (mounted) setState(() => _shared = list);
    }
  }

  void _toPoints() {
    setState(() => _step = _Step.points);
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

  List<Candidate> _localCandidates() => [
        for (final c in ref.read(localSignalStoreProvider))
          if (c.id != widget.locateId) ?c.toCandidate(),
      ];

  /// 등록 지도에 회색 선으로 그릴 기존 횡단보도 (FR-03-A-06)
  List<Candidate> _existing() {
    if (_me == null) return const [];
    ref.watch(localSignalStoreProvider);
    final all = ref.read(sessionProvider).loggedIn ? _shared : _localCandidates();
    // 끝점이 내 위치 50m 안이고 길이가 80m 이하면 중점은 90m 안이다
    return all.where((c) => distanceM(c.midpoint, _me!) <= existingRadiusM).toList();
  }

  String? _problem() {
    if (_me == null) return '내 위치를 확인하는 중이에요'; // 위치 전에는 50m 확인을 못 하니 다음으로 못 간다
    if (_points.length < 2) return null;
    final len = distanceM(_points[0], _points[1]);
    if (len < 3 || len > 80) return '횡단보도 길이는 3~80m여야 해요'; // FR-03-A-03
    if (_points.any((p) => distanceM(_me!, p) > 50)) return '내 위치에서 50m 안의 횡단보도만 지정할 수 있어요'; // FR-03-A-04
    return null;
  }

  /// 주변 횡단보도를 모아 중복·교차로 후보를 판정한다
  Future<void> _next() async {
    setState(() => _loading = true);
    final all = await _nearby();
    if (!mounted) return;
    final [a, b] = _points;
    setState(() {
      _loading = false;
      _suggestions = duplicates(all, a, b);
      _members = intersectionMembers(all, a, b);
    });
    if (_suggestions.isNotEmpty) {
      setState(() => _step = _Step.suggest);
    } else {
      _toGroupOrRecord();
    }
  }

  Future<List<Candidate>> _nearby() async {
    if (!ref.read(sessionProvider).loggedIn) return _localCandidates();
    return _sharedAround(mid(_points[0], _points[1]), 60); // 교차로 반경 40m를 덮는다
  }

  Future<List<Candidate>> _sharedAround(LatLng c, double radiusM) async {
    final dLat = radiusM / 111320;
    final dLng = radiusM / (111320 * math.cos(c.latitude * math.pi / 180));
    // 못 불러오면 빈 목록 — 등록은 계속하고 서버가 등록 때 다시 확인한다. 나만 보기는 서버가 보내지 않는다
    final list = await ref.read(serverSignalsProvider.notifier).loadBounds(c.longitude - dLng, c.latitude - dLat, c.longitude + dLng, c.latitude + dLat);
    return [
      for (final v in list)
        if (v.located && v.crosswalkId != widget.locateId)
          Candidate(id: v.crosswalkId, name: v.displayName, endA: LatLng(v.endA![1], v.endA![0]), endB: LatLng(v.endB![1], v.endB![0]), groupId: v.groupId),
    ];
  }

  /// 기존 횡단보도를 골랐다 (FR-03-B-02). 새 등록이면 그 횡단보도 기록으로, 위치 지정이면 내 기록을 그쪽으로 옮긴다 (F-03 E-11)
  Future<void> _pickExisting(Candidate c) async {
    if (_locating) return _applyLocation(mergeInto: c.id);
    if (ref.read(sessionProvider).loggedIn) {
      try {
        final repo = ref.read(signalRepositoryProvider);
        await repo.importSignal(c.id);
        if (_name.text.trim().isNotEmpty) await repo.updateSignal(c.id, alias: _name.text.trim()); // 입력한 이름 = 내 별칭
        await ref.read(serverSignalsProvider.notifier).refreshMine();
      } on ApiError {
        // 가져오기에 실패해도 기록하면 내 신호등에 자동으로 들어간다 (D-054)
      }
    }
    if (mounted) context.pushReplacement('/signal/record/${c.id}');
  }

  void _toGroupOrRecord() {
    // 교차로에 기존 횡단보도가 없으면 그룹 선택지가 없다 (F-03 E-05)
    if (_members.isEmpty) return _record();
    setState(() => _step = _Step.group);
  }

  void _record({String? join, bool scramble = false}) {
    if (_locating) {
      _applyLocation(join: join, scramble: scramble);
      return;
    }
    final name = _name.text.trim();
    context.pushReplacement(
      '/signal/record-new',
      extra: _points.length == 2
          ? PendingCrosswalk(_points[0], _points[1], name: name, joinCrosswalkId: join, scramble: scramble, checkedSuggestions: true)
          : PendingCrosswalk.private(name),
    );
  }

  /// 나만 보기 → 위치 지정 저장 (FR-03-A-08)
  Future<void> _applyLocation({String? join, bool scramble = false, String? mergeInto}) async {
    final [a, b] = _points;
    setState(() => _loading = true);
    try {
      final String id;
      if (ref.read(sessionProvider).loggedIn) {
        final r = await ref.read(signalRepositoryProvider).setLocation(
              widget.locateId!,
              endA: [a.longitude, a.latitude],
              endB: [b.longitude, b.latitude],
              skipSuggestion: true, // 이미 이 화면에서 물어봤다
              joinCrosswalkId: join,
              scramble: scramble,
              mergeInto: mergeInto,
            );
        id = r.crosswalkId!;
        await ref.read(serverSignalsProvider.notifier).refreshMine();
      } else {
        id = await ref.read(localSignalStoreProvider.notifier).setLocation(widget.locateId!, a, b, joinCrosswalkId: join, scramble: scramble, mergeInto: mergeInto);
      }
      if (!mounted) return;
      showToast(context, ref.read(sessionProvider).loggedIn ? '위치를 지정했어요 · 이제 다른 사람도 볼 수 있어요' : '위치를 지정했어요');
      context.pushReplacement('/signal/timer/$id');
    } on ApiError {
      if (!mounted) return;
      setState(() => _loading = false);
      showToast(context, '저장하지 못했어요. 연결을 확인해 주세요');
    }
  }

  @override
  Widget build(BuildContext context) => switch (_step) {
        _Step.name => _nameStep(context),
        _Step.points => _pointsStep(context),
        _Step.suggest => _suggestStep(context),
        _Step.group => _groupStep(context),
      };

  /// ① 이름 (FR-03-A-01). 위치는 선택
  Widget _nameStep(BuildContext context) {
    final ok = _name.text.trim().isNotEmpty;
    return ScreenScaffold(
      title: _title,
      actions: [
        Button('다음: 신호 기록', onPressed: ok ? () => _record() : null),
        Button.secondary('위치도 지정하기', icon: Icons.place_outlined, onPressed: ok ? _toPoints : null),
      ],
      children: [
        const ScreenHeader('어떤 신호등인가요?', description: '자주 보는 신호등 이름을 적어 주세요'),
        TextField(
          controller: _name,
          autofocus: true,
          maxLength: _nameMax,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => ok ? _record() : null,
          decoration: const InputDecoration(hintText: '예: 회사 앞 사거리'),
        ),
        const SizedBox(height: TokenSpace.s2),
        const Callout(
          title: '위치 없이도 등록할 수 있어요',
          body: '위치를 지정하지 않으면 나만 보는 신호등이 돼요. 횡단보도 앞에서 위치를 지정하면 다른 사람과 함께 볼 수 있어요',
          icon: Icons.lock_outline_rounded,
        ),
      ],
    );
  }

  Widget _pointsStep(BuildContext context) {
    final problem = _problem();
    final existing = _existing();
    return Scaffold(
      appBar: NavBar(title: _title),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(TokenSpace.s5, TokenSpace.s2, TokenSpace.s5, TokenSpace.s4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StepBar(done: _points.length, total: 2, semanticsLabel: '끝점 2개 중 ${_points.length}개 찍었어요'),
              const SizedBox(height: TokenSpace.s4),
              Text('횡단보도 양 끝을 지도에서 눌러 주세요', style: TokenTypography.title2.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w700)),
              const SizedBox(height: TokenSpace.s1),
              Text('길이 3~80m · 내 위치에서 50m 안', style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
              if (existing.isNotEmpty) Text('회색 선은 이미 등록된 횡단보도예요', style: TokenTypography.body2.copyWith(color: TokenColors.textTertiary)),
            ]),
          ),
          Expanded(
            child: OsmMap(
              controller: _map,
              center: _me ?? defaultCenter,
              onTap: (p) => setState(() => _points.length < 2 ? _points.add(p) : (_points..clear()..add(p))),
              layers: [
                if (existing.isNotEmpty)
                  PolylineLayer(polylines: [
                    for (final c in existing) Polyline(points: [c.endA, c.endB], strokeWidth: 6, color: TokenColors.textTertiary.withValues(alpha: 0.7)),
                  ]),
                if (_points.length == 2) PolylineLayer(polylines: [Polyline(points: _points, strokeWidth: 8, color: TokenColors.brandPrimary)]),
                MarkerLayer(markers: [
                  if (_me != null) Marker(point: _me!, child: const Icon(Icons.my_location_rounded, color: TokenColors.brandPrimary)),
                  for (final p in _points)
                    Marker(
                      point: p,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: TokenColors.brandPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: TokenColors.bgDefault, width: TokenStroke.edge),
                        ),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(children: [
        if (problem != null) Text(problem, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
        Button('다음', onPressed: _points.length == 2 && problem == null && !_loading ? _next : null),
      ]),
    );
  }

  /// "이 횡단보도인가요?" (FR-03-B-01·B-03)
  Widget _suggestStep(BuildContext context) => ScreenScaffold(
        title: _title,
        actions: [Button.secondary(_locating ? '아니요, 새 위치로 지정할게요' : '아니요, 새로 등록할게요', onPressed: _toGroupOrRecord)],
        children: [
          const ScreenHeader('이 횡단보도인가요?', description: '15m 안에 비슷한 방향으로 이미 등록돼 있어요'),
          for (final c in _suggestions) ListItem(title: c.name, leading: Icons.place_rounded, onTap: () => _pickExisting(c)),
        ],
      );

  /// 같이 켜지는 횡단보도 (FR-03-C-01~C-03). 건너뛸 수 있다
  Widget _groupStep(BuildContext context) => ScreenScaffold(
        title: _title,
        actions: [
          Button(
            _locating ? '위치 저장하기' : '다음: 신호 기록',
            onPressed: _groupChoice == null ? null : () => _groupChoice == _scrambleKey ? _record(scramble: true) : _record(join: _groupChoice),
          ),
          Button.text('건너뛰기', onPressed: _loading ? null : () => _record()), // FR-03-C-02 단독 그룹
        ],
        children: [
          const ScreenHeader('같이 켜지는 횡단보도가 있나요?', description: '같은 순간에 녹색이 켜지는 횡단보도를 골라 주세요. 모르면 건너뛰어도 돼요'),
          for (final c in _members)
            ChoiceCard(
              title: c.name,
              subtitle: '${distanceM(c.midpoint, mid(_points[0], _points[1])).round()}m 떨어짐',
              selected: _groupChoice == c.id,
              onTap: () => setState(() => _groupChoice = c.id),
            ),
          ChoiceCard(
            title: '전방향 동시 보행',
            subtitle: '이 교차로의 모든 횡단보도와 대각선이 한꺼번에 켜져요',
            selected: _groupChoice == _scrambleKey,
            onTap: () => setState(() => _groupChoice = _scrambleKey),
          ),
          const SizedBox(height: TokenSpace.s2),
          const FreshnessLabel('같이 켜진다고 골랐는데 첫 기록이 다르면 따로 등록해요'), // D-040
        ],
      );
}

