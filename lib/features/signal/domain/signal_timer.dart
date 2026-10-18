/// 신호 타이머 계산 (traffic-signal PRD 부록 A-1). 서버와 통신 없이 기기에서 계산한다 (D-037).
library;

enum SignalState {
  green('녹색'),
  red('적색');

  const SignalState(this.label);

  /// 화면 라벨. 건너라·기다리라는 지시를 쓰지 않는다 (D-059, D-060). 녹색 마지막 구간을 따로 나누지 않는다 (D-076)
  final String label;

  /// 보조 문구
  String get caption => switch (this) {
        SignalState.green => '녹색 남은 시간',
        SignalState.red => '다음 녹색까지',
      };
}

class SignalNow {
  const SignalNow({required this.state, required this.remaining, required this.barRatio});

  final SignalState state;

  /// 남은 시간 (초, 실수)
  final double remaining;

  /// 프로그래스바 남은 비율. 녹색은 G, 적색은 C − G 기준
  final double barRatio;

  /// 화면 표시용 정수 초 — 올림 (FR-02-A-04)
  int get displaySeconds => remaining.ceil();
}

/// [now]는 서버 시각으로 보정한 epoch 초 (FR-02-D-01)
SignalNow computeSignal({
  required int cycle,
  required int green,
  required double phase,
  required double now,
}) {
  final e = (now - phase) % cycle;
  final elapsed = e < 0 ? e + cycle : e;
  if (elapsed < green) {
    final remaining = green - elapsed;
    return SignalNow(
      state: SignalState.green,
      remaining: remaining,
      barRatio: remaining / green,
    );
  }
  final remaining = cycle - elapsed;
  return SignalNow(state: SignalState.red, remaining: remaining, barRatio: remaining / (cycle - green));
}
