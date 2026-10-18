import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/theme/tokens.g.dart';
import '../../../core/ui/ui.dart';
import '../../../core/auth/session.dart';
import '../data/local_signal_store.dart';
import '../data/server_signals.dart';
import '../data/signal_repository.dart';
import '../domain/record_sequence.dart';
import '../domain/signal_timer.dart';
import 'components/signal_components.dart';
import '../location/location_gate.dart';

/// 등록 중인 새 횡단보도 (FR-03-D: 첫 기록이 끝나야 확정)
class PendingCrosswalk {
  const PendingCrosswalk(this.endA, this.endB, {this.name, this.joinCrosswalkId, this.scramble = false, this.checkedSuggestions = false});

  /// 위치 없이 등록 (나만 보기, D-074)
  const PendingCrosswalk.private(String this.name)
      : endA = null,
        endB = null,
        joinCrosswalkId = null,
        scramble = false,
        checkedSuggestions = true;

  /// null이면 위치 없는 나만 보기
  final LatLng? endA;
  final LatLng? endB;

  /// 사용자가 입력한 이름 (위치 없으면 필수). 위치가 있으면 내 별칭으로 남는다
  final String? name;

  bool get located => endA != null && endB != null;

  /// 같이 켜지는 기존 횡단보도 (FR-03-C-04)
  final String? joinCrosswalkId;

  /// 전방향 동시 보행 (FR-03-C-03)
  final bool scramble;

  /// 기록 전에 "이 횡단보도인가요?"를 이미 물어봤으면 서버 제안을 다시 받지 않는다 (FR-03-B-03)
  final bool checkedSuggestions;
}

/// 신호 기록 (traffic-signal F-04). 기존 횡단보도면 [crosswalkId], 등록 중이면 [pending]
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, this.crosswalkId, this.pending});
  final String? crosswalkId;
  final PendingCrosswalk? pending;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> with WidgetsBindingObserver {
  final _seq = RecordSequence();
  Timer? _timeoutCheck;
  String? _stopped;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable(); // 기록 중 화면 꺼짐 방지 (FR-04-A-06)
    _timeoutCheck = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_seq.isTimedOut(nowEpoch())) _stop('5분 동안 누르지 않아 기록이 중단됐어요');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _timeoutCheck?.cancel();
    super.dispose();
  }

  // 앱이 백그라운드로 가면 중단 (FR-04-C-05)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _seq.taps.isNotEmpty) _stop('앱을 나가서 시간을 잴 수 없었어요');
  }

  void _stop(String reason) {
    if (!mounted || _stopped != null) return;
    setState(() => _stopped = reason);
  }

  Future<void> _tap(TapKind kind) async {
    setState(() => _seq.tap(kind, nowEpoch()));
    if (_seq.isComplete) await _finish();
  }

  /// 기록 대상 횡단보도의 위치. null = 위치 없는 나만 보기 — 현장 확인을 하지 않는다 (D-074)
  LatLng? _target() {
    if (widget.pending != null) return widget.pending!.endA;
    if (ref.read(sessionProvider).loggedIn) {
      final m = ref.read(serverSignalsProvider).byId[widget.crosswalkId!]?.midpoint;
      return m == null ? null : LatLng(m[1], m[0]);
    }
    return ref.read(localSignalStoreProvider.notifier).byId(widget.crosswalkId!)?.midpoint;
  }

  /// 위치 있는 신호등이면 현재 위치가 50m 안인지 (FR-04-C-01·C-02). 위치는 기기에서만 쓰고 저장하지 않는다.
  /// 통과하면 null, 아니면 중단 사유
  Future<String?> _checkOnSite(String failMessage) async {
    final target = _target();
    if (target == null) return null;
    final pos = await ensureLocation(context, action: '기록', needAccuracy: true);
    if (pos == null) return '위치를 확인하지 못해 저장하지 않았어요';
    if (const Distance().as(LengthUnit.Meter, LatLng(pos.latitude, pos.longitude), target) > 50) return failMessage;
    return null;
  }

  Future<void> _finish() async {
    final problem = await _checkOnSite('횡단보도에서 50m 넘게 떨어진 곳에서 끝나 저장하지 않았어요');
    if (!mounted) return;
    if (problem != null) return _stop(problem);
    final loggedIn = ref.read(sessionProvider).loggedIn;
    final store = ref.read(localSignalStoreProvider.notifier);

    final result = _seq.result()!;
    if (!result.ok) {
      return _stop(switch (result.error!) {
        RecordError.cycleOutOfRange => '잰 시간이 신호 주기 범위(20초~5분)를 벗어나 저장하지 않았어요',
        RecordError.greenOutOfRange => '녹색 시간이 너무 짧거나 길어 저장하지 않았어요',
        RecordError.timeout => '5분 동안 누르지 않아 기록이 중단됐어요',
      });
    }

    final taps = List.of(_seq.taps);
    if (!loggedIn) {
      // 로그인 전: 기기에만 저장 (D-048)
      final String id;
      if (widget.pending != null) {
        final p = widget.pending!;
        id = await store.register(p.endA, p.endB, result, name: p.name, taps: taps, joinCrosswalkId: p.joinCrosswalkId, scramble: p.scramble);
      } else {
        await store.addRecord(widget.crosswalkId!, result, taps: taps);
        id = widget.crosswalkId!;
      }
      if (!mounted) return;
      showToast(context, '기록했어요 · 내 기기에만 저장돼요');
      context.pushReplacement('/signal/timer/$id');
      return;
    }

    // 로그인: 서버에 저장 (F-04, F-03). 위치 있으면 공유, 없으면 나만 보기
    final repo = ref.read(signalRepositoryProvider);
    try {
      String id;
      String message;
      if (widget.pending case final p? when !p.located) {
        final r = await repo.register(name: p.name, taps: taps);
        id = r.crosswalkId!;
        message = '등록했어요 · 나만 보는 신호등이에요';
      } else if (widget.pending case final p?) {
        var r = await repo.register(
          endA: _ll(p.endA!),
          endB: _ll(p.endB!),
          taps: taps,
          joinCrosswalkId: p.joinCrosswalkId,
          scramble: p.scramble,
          skipSuggestion: p.checkedSuggestions,
        );
        if (r.suggestions.isNotEmpty) {
          // "이 횡단보도인가요?" (FR-03-B-01)
          if (!mounted) return;
          final picked = await _suggest(r.suggestions);
          if (picked != null) {
            await repo.submitRecord(picked, taps);
            await repo.importSignal(picked); // FR-03-B-02
            r = RegisterOutcome.created(picked);
          } else {
            r = await repo.register(endA: _ll(p.endA!), endB: _ll(p.endB!), taps: taps, joinCrosswalkId: p.joinCrosswalkId, scramble: p.scramble, skipSuggestion: true);
          }
        }
        id = r.crosswalkId!;
        if (p.name != null && r.suggestions.isEmpty) await repo.updateSignal(id, alias: p.name); // 입력한 이름 = 내 별칭 (D-074)
        message = r.joinRejected ? '따로 등록했어요 · 기존 횡단보도와 같이 켜지지 않는 것 같아요' : '등록하고 공개했어요';
      } else {
        final outcome = await repo.submitRecord(widget.crosswalkId!, taps);
        id = widget.crosswalkId!;
        final private = ref.read(serverSignalsProvider).byId[id]?.isPrivate ?? false;
        message = private
            ? '기록했어요'
            : switch (outcome) {
                'match' => '다른 사람 기록과 맞았어요',
                'mismatch' => '기존 정보와 달라서 따로 보관했어요',
                'replaced' => '새 기록으로 바뀌었어요',
                _ => '검증 전으로 공개됐어요',
              };
      }
      await ref.read(serverSignalsProvider.notifier).refreshMine();
      if (!mounted) return;
      showToast(context, message);
      context.pushReplacement('/signal/timer/$id');
    } on ApiError catch (e) {
      _stop(e.code == 'sanctioned' ? '지금은 기록할 수 없어요' : '서버에 저장하지 못했어요. 연결을 확인해 주세요');
    }
  }

  Future<void> _markButton() async {
    final problem = await _checkOnSite('횡단보도에서 50m 넘게 떨어져 있어요'); // 50m 조건 (FR-04-D-02) — 위치 있는 신호등만
    if (!mounted) return;
    if (problem != null) return _stop(problem);
    if (!ref.read(sessionProvider).loggedIn) return _markButtonLocal();
    final repo = ref.read(signalRepositoryProvider);
    try {
      final String id;
      if (widget.pending case final p?) {
        final r = p.located
            ? await repo.register(endA: _ll(p.endA!), endB: _ll(p.endB!), buttonType: true, skipSuggestion: true)
            : await repo.register(name: p.name, buttonType: true);
        id = r.crosswalkId!;
      } else {
        await repo.markButton(widget.crosswalkId!);
        id = widget.crosswalkId!;
      }
      await ref.read(serverSignalsProvider.notifier).refreshMine();
      if (!mounted) return;
      showToast(context, '버튼식 신호로 표시했어요');
      context.pushReplacement('/signal/timer/$id');
    } on ApiError {
      _stop('서버에 저장하지 못했어요. 연결을 확인해 주세요');
    }
  }

  /// 로그인 전: 기기에만 저장 (D-048). 사용자 1명이라 늘 "버튼식 (검증 전)"
  Future<void> _markButtonLocal() async {
    final store = ref.read(localSignalStoreProvider.notifier);
    final String id;
    if (widget.pending case final p?) {
      id = await store.register(p.endA, p.endB, null, name: p.name, joinCrosswalkId: p.joinCrosswalkId, scramble: p.scramble);
    } else {
      await store.markButton(widget.crosswalkId!);
      id = widget.crosswalkId!;
    }
    if (!mounted) return;
    showToast(context, '버튼식 신호로 표시했어요 · 내 기기에만 저장돼요');
    context.pushReplacement('/signal/timer/$id');
  }

  static List<double> _ll(LatLng p) => [p.longitude, p.latitude];

  Future<String?> _suggest(List<(String, String)> options) => showAppSheet<String>(
        context,
        title: '이 횡단보도인가요?',
        body: '15m 안에 비슷한 방향으로 이미 등록돼 있어요',
        children: (context) => [
          for (final (id, name) in options) ListItem(title: name, leading: Icons.place_rounded, onTap: () => Navigator.pop(context, id)),
          Button.secondary('아니요, 새로 등록할게요', onPressed: () => Navigator.pop(context)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final last = _seq.taps.lastOrNull?.kind;
    final next = _seq.isComplete ? '위치를 확인하고 저장하는 중이에요' : last == null ? '먼저 오는 전환을 눌러 주세요' : last == TapKind.green ? '적색으로 바뀌는 순간에 눌러 주세요' : '녹색으로 바뀌는 순간에 눌러 주세요';

    if (_stopped != null) {
      return ScreenScaffold(
        title: '신호 기록',
        actions: [Button('닫기', onPressed: () => context.pop())],
        children: [EmptyState(title: '저장하지 않았어요', body: _stopped, icon: Icons.block_rounded)],
      );
    }
    return ScreenScaffold(
      title: '신호 기록',
      children: [
        StepBar(done: _seq.taps.length, total: 3, semanticsLabel: '3번 중 ${_seq.taps.length}번 눌렀어요'),
        const SizedBox(height: TokenSpace.s5),
        ScreenHeader(next, description: '신호를 보면서 바뀌는 순간에 눌러 주세요'),
        _TapPad(kind: TapKind.green, label: '녹색 켜짐', onTap: _seq.canTap(TapKind.green) ? () => _tap(TapKind.green) : null),
        const SizedBox(height: TokenSpace.s3),
        _TapPad(kind: TapKind.red, label: '적색 켜짐', onTap: _seq.canTap(TapKind.red) ? () => _tap(TapKind.red) : null),
        const SizedBox(height: TokenSpace.s4),
        Button.text('직전 탭 되돌리기', icon: Icons.undo_rounded, onPressed: _seq.canUndo ? () => setState(_seq.undo) : null),
        // 버튼식 표시 (FR-04-D-01·D-02, D-042). 로그인 전에는 기기에 저장
        Button.text('버튼을 눌러야 켜지는 신호예요', icon: Icons.touch_app_outlined, onPressed: _markButton),
        const SizedBox(height: TokenSpace.s4),
        const FreshnessLabel('기록 중에는 화면이 꺼지지 않아요 · 5분 동안 누르지 않거나 앱을 나가면 중단돼요'),
      ],
    );
  }
}

/// 전환 순간을 누르는 큰 판. 신호색은 신호 모양(원·사각)에만 쓴다 (design-guide 3-1)
class _TapPad extends StatelessWidget {
  const _TapPad({required this.kind, required this.label, required this.onTap});
  final TapKind kind;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final (color, shape) = signalLook(context, kind == TapKind.green ? SignalState.green : SignalState.red);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: PressableSurface(
        face: enabled ? TokenColors.bgDefault : TokenColors.bgSubtle,
        edge: TokenColors.borderStrong,
        border: enabled ? TokenColors.borderStrong : TokenColors.borderDefault,
        onTap: onTap,
        minHeight: 112,
        padding: const EdgeInsets.symmetric(horizontal: TokenSpace.s5, vertical: TokenSpace.s4),
        child: Row(children: [
          Opacity(
            opacity: enabled ? 1 : 0.35,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: shape,
                borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(TokenRadius.sm) : null,
              ),
            ),
          ),
          const SizedBox(width: TokenSpace.s4),
          Text(label, style: TokenTypography.title1.copyWith(color: enabled ? TokenColors.textPrimary : TokenColors.textTertiary)),
        ]),
      ),
    );
  }
}
