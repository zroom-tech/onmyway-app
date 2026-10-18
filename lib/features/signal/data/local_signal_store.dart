import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../domain/record_sequence.dart';
import '../domain/register_candidates.dart';
import 'local_db.dart';

/// 로그인 전 기기 기록 (traffic-signal D-047·D-048). 서버로 보내지 않는다.
///
/// 기기 SQLite(drift)에 저장해 앱을 다시 켜도 남는다 (D-066).
class LocalCrosswalk {
  const LocalCrosswalk({
    required this.id,
    required this.endA,
    required this.endB,
    required this.name,
    required this.records,
    required this.groupId,
    this.scramble = false,
    this.buttonMarked = false,
  });

  final String id;

  /// null이면 위치 없는 나만 보기 신호등 (D-074)
  final LatLng? endA;
  final LatLng? endB;

  /// 위치 없는 신호등은 사용자가 입력한 이름, 위치만 있으면 임시 이름 (D-067, D-074)
  final String name;
  final List<LocalRecord> records;

  /// 같은 순간 녹색이 켜지는 묶음 (D-010). 묶인 횡단보도는 기록을 함께 쓴다
  final String groupId;

  /// 전방향 동시 보행 그룹 (FR-03-C-03)
  final bool scramble;

  /// 내가 버튼식으로 표시함 (FR-04-D-02)
  final bool buttonMarked;

  bool get located => endA != null && endB != null;

  /// 위치 없으면 null
  LatLng? get midpoint => located ? mid(endA!, endB!) : null;

  /// 그룹 × 시간대 구간마다 최근 1건 (FR-02-E-01)
  LocalRecord? latestIn(Slot slot) {
    final inSlot = records.where((r) => r.slot == slot).toList()..sort((a, b) => b.at.compareTo(a.at));
    return inSlot.isEmpty ? null : inSlot.first;
  }

  /// 등록 후보 판정용 — 위치 없는 신호등은 후보가 아니다 (FR-03-A-07)
  Candidate? toCandidate() => located ? Candidate(id: id, name: name, endA: endA!, endB: endB!, groupId: groupId) : null;
}

class LocalRecord {
  const LocalRecord({required this.cycle, required this.green, required this.phase, required this.at, required this.slot, this.taps = const []});

  final int cycle;
  final int green;
  final double phase;
  final double at;
  final Slot slot;

  /// 탭 원본 — 업로드용 (FR-08-D-02)
  final List<Tap> taps;
}

/// 시간대 구간 = 1시간 × 평일/주말 (D-031). 기준 시간대 KST.
/// 공휴일 목록은 서버 데이터라 로그인 전에는 토·일만 주말로 본다 [가정]
class Slot {
  const Slot(this.weekend, this.hour);
  final bool weekend;
  final int hour;

  factory Slot.of(double epochSec) {
    final kst = DateTime.fromMillisecondsSinceEpoch((epochSec * 1000).round(), isUtc: true).add(const Duration(hours: 9));
    return Slot(kst.weekday == DateTime.saturday || kst.weekday == DateTime.sunday, kst.hour);
  }

  @override
  bool operator ==(Object other) => other is Slot && other.weekend == weekend && other.hour == hour;
  @override
  int get hashCode => Object.hash(weekend, hour);
}

double nowEpoch() => DateTime.now().millisecondsSinceEpoch / 1000;

class LocalSignalStore extends Notifier<List<LocalCrosswalk>> {
  late final LocalDb _db;

  /// 저장소에서 처음 불러오기가 끝나면 완료된다
  late Future<void> ready;

  @override
  List<LocalCrosswalk> build() {
    _db = ref.watch(localDbProvider);
    ready = _load();
    return const [];
  }

  Future<void> _load() async {
    final cws = await (_db.select(_db.localCrosswalks)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    final recs = await _db.select(_db.localRecords).get();
    state = [
      for (final c in cws)
        LocalCrosswalk(
          id: c.id,
          endA: c.aLat == null ? null : LatLng(c.aLat!, c.aLng!),
          endB: c.bLat == null ? null : LatLng(c.bLat!, c.bLng!),
          name: c.name,
          groupId: c.groupId.isEmpty ? c.id : c.groupId,
          scramble: c.scramble,
          buttonMarked: c.buttonMarked,
          records: [
            for (final r in recs.where((r) => r.crosswalkId == c.id))
              LocalRecord(cycle: r.cycle, green: r.green, phase: r.phase, at: r.at, slot: Slot(r.weekend, r.hour), taps: _decodeTaps(r.tapsJson)),
          ],
        ),
    ];
  }

  LocalCrosswalk? byId(String id) => state.where((c) => c.id == id).firstOrNull;

  /// 그룹 × 시간대 구간의 내 최근 기록 (FR-02-E-01). 묶인 횡단보도 어디서 잰 기록이든 쓴다
  LocalRecord? latestForGroup(String groupId, Slot slot) {
    final recs = [for (final c in state.where((c) => c.groupId == groupId)) ...c.records.where((r) => r.slot == slot)]
      ..sort((a, b) => b.at.compareTo(a.at));
    return recs.firstOrNull;
  }

  /// 그룹 안 어느 횡단보도든 버튼식으로 표시했으면 그룹 전체가 버튼식 (검증 전) (D-025: 버튼식은 신호 그룹 단위)
  bool groupButtonMarked(String groupId) => state.any((c) => c.groupId == groupId && c.buttonMarked);

  List<Candidate> get _candidates => [for (final c in state) ?c.toCandidate()];

  /// 그룹: 합류 대상의 그룹 / 전방향이면 40m 안 내 횡단보도 전부 / 아니면 단독 (FR-03-C, FR-03-D-05)
  Future<(String, bool)> _assignGroup(String id, LatLng a, LatLng b, {String? joinCrosswalkId, bool scramble = false}) async {
    var groupId = id;
    var groupScramble = scramble;
    if (joinCrosswalkId != null) {
      final target = byId(joinCrosswalkId);
      groupId = target?.groupId ?? id;
      groupScramble = groupScramble || (target?.scramble ?? false);
    }
    final members = scramble ? intersectionMembers(_candidates.where((c) => c.id != id).toList(), a, b) : const <Candidate>[];
    if (members.isNotEmpty) {
      await (_db.update(_db.localCrosswalks)..where((t) => t.id.isIn(members.map((m) => m.id))))
          .write(LocalCrosswalksCompanion(groupId: Value(groupId), scramble: const Value(true)));
    }
    return (groupId, groupScramble);
  }

  /// 등록 + 첫 기록 (FR-03-D-02·D-05: 첫 기록 완료 시 확정, 기기에만 저장).
  /// [a]·[b]가 null이면 위치 없는 나만 보기 — [name] 필수 (D-074).
  /// [r]이 null이면 첫 단계에서 버튼식으로 표시한 등록 (FR-03-D-03)
  Future<String> register(LatLng? a, LatLng? b, RecordResult? r, {String? name, List<Tap> taps = const [], String? joinCrosswalkId, bool scramble = false}) async {
    final id = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final located = a != null && b != null;
    assert(located || (name?.trim().isNotEmpty ?? false), '위치 없는 등록은 이름이 필요하다');
    // 로그인 전에는 장소 역검색을 하지 않는다 — 이름을 안 받았으면 임시 이름 (D-067)
    final label = name?.trim().isNotEmpty ?? false ? name!.trim() : '내가 기록한 횡단보도 ${state.length + 1}';
    await _db.transaction(() async {
      final (groupId, groupScramble) = located ? await _assignGroup(id, a, b, joinCrosswalkId: joinCrosswalkId, scramble: scramble) : (id, false);
      await _db.into(_db.localCrosswalks).insert(LocalCrosswalksCompanion.insert(
            id: id,
            aLat: Value(a?.latitude),
            aLng: Value(a?.longitude),
            bLat: Value(b?.latitude),
            bLng: Value(b?.longitude),
            name: label,
            groupId: Value(groupId),
            scramble: Value(groupScramble),
            buttonMarked: Value(r == null),
          ));
      if (r != null) await _insertRecord(id, r, taps);
    });
    await _load();
    return id;
  }

  /// 나만 보기 신호등에 위치 지정 (FR-03-A-08). [mergeInto]면 그 기기 횡단보도로 기록을 옮기고 이 신호등은 지운다 (F-03 E-11).
  /// 결과는 남는 횡단보도 id
  Future<String> setLocation(String id, LatLng a, LatLng b, {String? joinCrosswalkId, bool scramble = false, String? mergeInto}) async {
    final cw = byId(id)!;
    await _db.transaction(() async {
      if (mergeInto != null) {
        await (_db.update(_db.localRecords)..where((t) => t.crosswalkId.equals(id))).write(LocalRecordsCompanion(crosswalkId: Value(mergeInto)));
        if (cw.buttonMarked) {
          await (_db.update(_db.localCrosswalks)..where((t) => t.id.equals(mergeInto))).write(const LocalCrosswalksCompanion(buttonMarked: Value(true)));
        }
        await (_db.delete(_db.localCrosswalks)..where((t) => t.id.equals(id))).go();
        return;
      }
      final (groupId, groupScramble) = await _assignGroup(id, a, b, joinCrosswalkId: joinCrosswalkId, scramble: scramble);
      await (_db.update(_db.localCrosswalks)..where((t) => t.id.equals(id))).write(LocalCrosswalksCompanion(
            aLat: Value(a.latitude),
            aLng: Value(a.longitude),
            bLat: Value(b.latitude),
            bLng: Value(b.longitude),
            groupId: Value(groupId),
            scramble: Value(groupScramble),
          ));
    });
    await _load();
    return mergeInto ?? id;
  }

  /// 기존 기기 횡단보도에 버튼식 표시 (FR-04-D-02)
  Future<void> markButton(String id) async {
    await (_db.update(_db.localCrosswalks)..where((t) => t.id.equals(id))).write(const LocalCrosswalksCompanion(buttonMarked: Value(true)));
    await _load();
  }

  Future<void> addRecord(String id, RecordResult r, {List<Tap> taps = const []}) async {
    await _insertRecord(id, r, taps);
    await _load();
  }

  /// 로그아웃·업로드 거절·업로드 완료 시 (FR-08-B-01, FR-08-D-02·D-03)
  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.localRecords).go();
      await _db.delete(_db.localCrosswalks).go();
    });
    state = const [];
  }

  Future<void> _insertRecord(String crosswalkId, RecordResult r, List<Tap> taps) {
    final slot = Slot.of(r.t0);
    return _db.into(_db.localRecords).insert(LocalRecordsCompanion.insert(
          crosswalkId: crosswalkId,
          cycle: r.cycle,
          green: r.green,
          phase: r.t0 % r.cycle,
          at: r.t0,
          weekend: slot.weekend,
          hour: slot.hour,
          tapsJson: Value(jsonEncode([for (final t in taps) t.toJson()])),
        ));
  }

  static List<Tap> _decodeTaps(String json) => [
        for (final t in jsonDecode(json) as List)
          Tap(TapKind.values.byName((t as Map)['kind'] as String), (t['at'] as num).toDouble()),
      ];
}

final localSignalStoreProvider = NotifierProvider<LocalSignalStore, List<LocalCrosswalk>>(LocalSignalStore.new);
