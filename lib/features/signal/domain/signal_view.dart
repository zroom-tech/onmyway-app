/// 서버 `GET /api/signals` 응답 한 건. 계약 기준: onmyway-next `src/lib/signal/service.ts`의 `SignalView`
library;

class SignalParams {
  const SignalParams({required this.cycle, required this.green, required this.phase});
  final int cycle;
  final int green;
  final double phase;

  factory SignalParams.fromJson(Map<String, dynamic> j) =>
      SignalParams(cycle: (j['C'] as num).toInt(), green: (j['G'] as num).toInt(), phase: (j['phase'] as num).toDouble());
}

class MyRecord extends SignalParams {
  const MyRecord({required super.cycle, required super.green, required super.phase, required this.at, required this.matchesAggregate});
  final double at;
  final bool matchesAggregate;

  factory MyRecord.fromJson(Map<String, dynamic> j) => MyRecord(
        cycle: (j['C'] as num).toInt(),
        green: (j['G'] as num).toInt(),
        phase: (j['phase'] as num).toDouble(),
        at: (j['at'] as num).toDouble(),
        matchesAggregate: j['matchesAggregate'] as bool,
      );
}

class SignalView {
  const SignalView({
    required this.crosswalkId,
    required this.groupId,
    required this.sharedName,
    required this.alias,
    required this.endA,
    required this.endB,
    this.isPrivate = false,
    required this.serverTime,
    required this.buttonType,
    required this.infoLevel,
    required this.verification,
    required this.recordCount,
    required this.lastMatchAt,
    required this.aggregate,
    required this.mine,
    required this.displaySource,
    required this.replacedBySignalChange,
  });

  final String crosswalkId;
  final String groupId;
  /// 나만 보기면 null — 이름은 [alias] (D-074)
  final String? sharedName;
  final String? alias;

  /// [lng, lat]. 나만 보기면 null
  final List<double>? endA;
  final List<double>? endB;

  /// 위치 없는 나만 보기 신호등 (D-074)
  final bool isPrivate;
  final double serverTime;

  /// none | unverified | confirmed
  final String buttonType;

  /// fresh | stale | expired | nodata
  final String infoLevel;

  /// unverified | confirmed
  final String verification;
  final int recordCount;
  final double? lastMatchAt;
  final SignalParams? aggregate;
  final MyRecord? mine;

  /// mine | aggregate
  final String displaySource;
  final bool replacedBySignalChange;

  bool get located => endA != null && endB != null;

  /// 나만 보기면 null
  List<double>? get midpoint => located ? [(endA![0] + endB![0]) / 2, (endA![1] + endB![1]) / 2] : null;

  /// 별칭 우선 (FR-01-D-08). 나만 보기는 별칭이 곧 이름
  String get displayName => alias ?? sharedName ?? '';

  factory SignalView.fromJson(Map<String, dynamic> j) {
    List<double>? pt(Object? v) => v == null ? null : (v as List).map((e) => (e as num).toDouble()).toList();
    return SignalView(
      crosswalkId: j['crosswalkId'] as String,
      groupId: j['groupId'] as String,
      sharedName: j['sharedName'] as String?,
      alias: j['alias'] as String?,
      endA: pt(j['endA']),
      endB: pt(j['endB']),
      isPrivate: j['isPrivate'] as bool? ?? false,
      serverTime: (j['serverTime'] as num).toDouble(),
      buttonType: j['buttonType'] as String,
      infoLevel: j['infoLevel'] as String,
      verification: j['verification'] as String,
      recordCount: (j['recordCount'] as num).toInt(),
      lastMatchAt: (j['lastMatchAt'] as num?)?.toDouble(),
      aggregate: j['aggregate'] == null ? null : SignalParams.fromJson(j['aggregate'] as Map<String, dynamic>),
      mine: j['mine'] == null ? null : MyRecord.fromJson(j['mine'] as Map<String, dynamic>),
      displaySource: j['displaySource'] as String,
      replacedBySignalChange: j['replacedBySignalChange'] as bool,
    );
  }
}
