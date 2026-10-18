import '../domain/record_sequence.dart';
import '../domain/signal_view.dart';
import 'signal_repository.dart';

/// 개발용 가짜 백엔드 (BACKEND=fake). 서버 없이 로그인 이후 화면을 확인하려고 둔다.
/// 집계 규칙은 흉내만 낸다 — 실제 규칙은 onmyway-next `src/lib/signal`이 기준이다.
class FakeSignalRepository implements SignalRepository {
  FakeSignalRepository() {
    _add('F1', '서울시청 앞 · 북쪽 횡단보도', [126.9776, 37.5667], [126.9782, 37.5667], level: 'fresh', verification: 'confirmed', count: 5);
    _add('F2', '덕수궁 대한문 앞 횡단보도', [126.9761, 37.5658], [126.9761, 37.5652], level: 'stale', verification: 'confirmed', count: 3);
    _add('F3', '을지로입구역 2번 출구 앞 횡단보도', [126.9819, 37.5662], [126.9819, 37.5657], level: 'fresh', verification: 'unverified', count: 1);
    _add('F4', '서울도서관 앞 횡단보도', [126.9772, 37.5655], [126.9778, 37.5655], button: 'confirmed');
  }

  final _all = <String, Map<String, dynamic>>{};
  final _mine = <String>{};
  final _alias = <String, String>{};
  final _showAgg = <String, bool>{};
  final _myRecords = <String, Map<String, dynamic>>{};
  final _reported = <String>{};
  int _seq = 0;

  double get _now => DateTime.now().millisecondsSinceEpoch / 1000;

  void _add(String id, String? name, List<double>? a, List<double>? b,
      {String level = 'fresh', String verification = 'confirmed', int count = 2, String button = 'none'}) {
    _all[id] = {
      'crosswalkId': id,
      'groupId': 'G$id',
      'sharedName': name,
      'endA': a,
      'endB': b,
      'isPrivate': a == null,
      'buttonType': button,
      'infoLevel': button == 'none' ? level : 'nodata',
      'verification': verification,
      'recordCount': button == 'none' ? count : 0,
      'lastMatchAt': _now - 86400,
      'aggregate': button == 'none' ? {'C': 120, 'G': 30, 'phase': 4.8} : null,
    };
  }

  SignalView _view(String id) {
    final mine = _myRecords[id];
    return SignalView.fromJson({
      ..._all[id]!,
      'alias': _alias[id],
      'serverTime': _now,
      'mine': mine,
      'displaySource': mine != null && _showAgg[id] != true ? 'mine' : 'aggregate',
      'replacedBySignalChange': false,
    });
  }

  @override
  Future<SignalsResult> mySignals() async => SignalsResult(_now, [for (final id in _mine) _view(id)]);

  @override
  Future<SignalsResult> inBounds(double minLng, double minLat, double maxLng, double maxLat) async => SignalsResult(_now, [
        for (final id in _all.keys)
          if (_inside(_all[id]!, minLng, minLat, maxLng, maxLat)) _view(id),
      ]);

  bool _inside(Map<String, dynamic> c, double minLng, double minLat, double maxLng, double maxLat) {
    final a = c['endA'] as List<double>?;
    if (a == null) return false; // 나만 보기는 지도에 없다 (D-074)
    return a[0] >= minLng && a[0] <= maxLng && a[1] >= minLat && a[1] <= maxLat;
  }

  @override
  Future<String> submitRecord(String crosswalkId, List<Tap> taps) async {
    if (_all[crosswalkId]?['buttonType'] == 'confirmed') throw const ApiError('button_signal');
    final startsGreen = taps.first.kind == TapKind.green;
    final t0 = startsGreen ? taps[0].at : taps[1].at;
    final c = (taps[2].at - taps[0].at).round();
    _myRecords[crosswalkId] = {'C': c, 'G': ((startsGreen ? taps[1].at - taps[0].at : taps[2].at - taps[1].at)).round(), 'phase': t0 % c, 'at': taps[0].at, 'matchesAggregate': c == 120};
    _mine.add(crosswalkId); // D-054
    _showAgg.remove(crosswalkId);
    return c == 120 ? 'match' : 'mismatch';
  }

  @override
  Future<RegisterOutcome> register({
    LngLat? endA,
    LngLat? endB,
    String? name,
    List<Tap>? taps,
    bool buttonType = false,
    bool skipSuggestion = false,
    String? joinCrosswalkId,
    bool scramble = false,
  }) async {
    final id = 'N${++_seq}';
    final located = endA != null && endB != null;
    _add(id, located ? '새로 등록한 횡단보도 $_seq' : null, endA, endB, button: buttonType ? 'unverified' : 'none', verification: 'unverified', count: 1);
    if (!located) _alias[id] = name ?? '내 신호등';
    _mine.add(id);
    if (taps != null) await submitRecord(id, taps);
    return RegisterOutcome.created(id);
  }

  @override
  Future<RegisterOutcome> setLocation(String crosswalkId, {required LngLat endA, required LngLat endB, bool skipSuggestion = false, String? joinCrosswalkId, bool scramble = false, String? mergeInto}) async {
    final c = _all[crosswalkId]!;
    _all[crosswalkId] = {...c, 'endA': endA, 'endB': endB, 'isPrivate': false, 'sharedName': '위치를 지정한 횡단보도 ${++_seq}'};
    return RegisterOutcome.created(crosswalkId);
  }

  @override
  Future<void> report(String crosswalkId, String kind) async {
    if (!_reported.add(crosswalkId)) throw const ApiError('already_reported_today');
  }

  @override
  Future<void> importSignal(String crosswalkId) async => _mine.add(crosswalkId);
  @override
  Future<void> removeSignal(String crosswalkId) async => _mine.remove(crosswalkId);
  @override
  Future<void> updateSignal(String crosswalkId, {String? alias, bool clearAlias = false, bool? showAggregate}) async {
    if (clearAlias) _alias.remove(crosswalkId);
    if (alias != null) _alias[crosswalkId] = alias;
    if (showAggregate != null) _showAgg[crosswalkId] = showAggregate;
  }

  @override
  Future<void> upload(List<UploadItem> items) async {
    for (final i in items) {
      final r = await register(endA: i.endA, endB: i.endB, name: i.name, taps: i.records.isEmpty ? null : i.records.first);
      if (r.crosswalkId == null) continue;
    }
  }

  @override
  Future<void> markButton(String crosswalkId) async {
    _mine.add(crosswalkId);
  }
}
