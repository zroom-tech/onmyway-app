// traffic-signal PRD 부록 A-1·A-2, F-02·F-04 인수 조건 기준 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:onmyway/features/signal/domain/record_sequence.dart';
import 'package:onmyway/features/signal/domain/signal_timer.dart';

void main() {
  group('computeSignal (부록 A-1)', () {
    // 위상 0 = epoch 0에 녹색 켜짐. C=120, G=30
    SignalNow at(double elapsed) =>
        computeSignal(cycle: 120, green: 30, phase: 0, now: 120 * 1000 + elapsed);

    test('AC-02-A-02-1 녹색 10.4초 경과 → 20초, 바 65.3%', () {
      final s = at(10.4);
      expect(s.state, SignalState.green);
      expect(s.displaySeconds, 20);
      expect(s.barRatio, closeTo(19.6 / 30, 1e-6));
    });

    test('AC-02-A-03-1 적색 50초 경과 → 70초, 바 77.8%', () {
      final s = at(50);
      expect(s.state, SignalState.red);
      expect(s.displaySeconds, 70);
      expect(s.barRatio, closeTo(70 / 90, 1e-6));
    });

    test('AC-02-B-01-1 녹색 9초 남음 → 끝까지 녹색 (D-076)', () {
      expect(at(21).state, SignalState.green);
      expect(at(21).displaySeconds, 9);
    });

    test('신호 상태는 녹색·적색 두 가지 (D-076)', () {
      expect(SignalState.values, [SignalState.green, SignalState.red]);
      expect(computeSignal(cycle: 60, green: 8, phase: 0, now: 600).state, SignalState.green);
    });

    test('E-08 남은 0.2초 → 1 (올림)', () {
      expect(at(29.8).displaySeconds, 1);
    });

    test('라벨은 사실만 (D-059, D-060)', () {
      expect(SignalState.green.label, '녹색');
      expect(SignalState.red.label, '적색');
      for (final s in SignalState.values) {
        expect(s.label.contains('건너'), isFalse);
        expect(s.label.contains('기다려'), isFalse);
      }
    });
  });

  group('RecordSequence (FR-04-A, 부록 A-2)', () {
    test('먼저 오는 전환부터, 이후 교대만 허용', () {
      final seq = RecordSequence();
      expect(seq.canTap(TapKind.green), isTrue);
      expect(seq.canTap(TapKind.red), isTrue);
      seq.tap(TapKind.green, 0);
      expect(seq.canTap(TapKind.green), isFalse);
      expect(seq.canTap(TapKind.red), isTrue);
    });

    test('되돌리기는 연속 1회 (FR-04-A-05)', () {
      final seq = RecordSequence()
        ..tap(TapKind.green, 0)
        ..tap(TapKind.red, 30);
      expect(seq.undo(), isTrue);
      expect(seq.taps.length, 1);
      expect(seq.undo(), isFalse);
    });

    test('AC-04-A-03-2 적→녹→적 완료', () {
      final seq = RecordSequence()
        ..tap(TapKind.red, 1000.0)
        ..tap(TapKind.green, 1090.2)
        ..tap(TapKind.red, 1120.1);
      final r = seq.result()!;
      expect(r.ok, isTrue);
      expect(r.cycle, 120);
      expect(r.green, 30);
      expect(r.t0, 1090.2);
    });

    test('AC-04-B-02-1 주기 범위 밖 → 저장 불가', () {
      final seq = RecordSequence()
        ..tap(TapKind.green, 0)
        ..tap(TapKind.red, 40)
        ..tap(TapKind.green, 330);
      expect(seq.result()!.error, RecordError.cycleOutOfRange);
    });

    test('탭 간격 300초 초과 → 중단 (FR-04-C-04)', () {
      final seq = RecordSequence()..tap(TapKind.green, 0);
      expect(seq.isTimedOut(301), isTrue);
      expect(seq.isTimedOut(299), isFalse);
    });
  });
}
