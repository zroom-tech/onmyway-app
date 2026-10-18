/// 신호 기록 탭 순서 (traffic-signal PRD F-04, 부록 A-2). 서버(onmyway-next src/lib/signal/record.ts)와 같은 규칙.
library;

enum TapKind { green, red }

class Tap {
  const Tap(this.kind, this.at);
  final TapKind kind;

  /// 서버 시각으로 보정한 epoch 초 (FR-04-A-04)
  final double at;

  Map<String, Object> toJson() => {'kind': kind.name, 'at': at};
}

enum RecordError { cycleOutOfRange, greenOutOfRange, timeout }

class RecordResult {
  const RecordResult.ok({required this.cycle, required this.green, required this.t0}) : error = null;
  const RecordResult.fail(RecordError this.error)
      : cycle = 0,
        green = 0,
        t0 = 0;

  final int cycle;
  final int green;
  final double t0;
  final RecordError? error;
  bool get ok => error == null;
}

/// 운영 설정값 초기값 (D-026)
const _cycleMin = 20, _cycleMax = 300, _greenMin = 5, _tapTimeout = 300;

class RecordSequence {
  final List<Tap> taps = [];
  bool _undoUsed = false;

  bool get isComplete => taps.length == 3;
  bool get canUndo => taps.isNotEmpty && !_undoUsed;

  /// 첫 탭은 아무 전환이나, 이후는 반대 전환만 (FR-04-A-01·A-02)
  bool canTap(TapKind kind) => !isComplete && (taps.isEmpty || taps.last.kind != kind);

  void tap(TapKind kind, double at) {
    if (!canTap(kind)) return;
    taps.add(Tap(kind, at));
    _undoUsed = false;
  }

  /// 직전 탭 1회 되돌리기. 연속 되돌리기는 1회까지 (FR-04-A-05)
  bool undo() {
    if (!canUndo) return false;
    taps.removeLast();
    _undoUsed = true;
    return true;
  }

  /// 마지막 탭 후 300초 동안 다음 탭이 없으면 중단 (FR-04-C-04)
  bool isTimedOut(double now) => taps.isNotEmpty && !isComplete && now - taps.last.at > _tapTimeout;

  RecordResult? result() {
    if (!isComplete) return null;
    final [t1, t2, t3] = taps;
    if (t2.at - t1.at > _tapTimeout || t3.at - t2.at > _tapTimeout) return const RecordResult.fail(RecordError.timeout);
    final startsGreen = t1.kind == TapKind.green;
    final t0 = startsGreen ? t1.at : t2.at;
    final green = (startsGreen ? t2.at - t1.at : t3.at - t2.at).round();
    final cycle = (t3.at - t1.at).round();
    if (cycle < _cycleMin || cycle > _cycleMax) return const RecordResult.fail(RecordError.cycleOutOfRange);
    if (green < _greenMin || green >= cycle) return const RecordResult.fail(RecordError.greenOutOfRange);
    return RecordResult.ok(cycle: cycle, green: green, t0: t0);
  }
}
