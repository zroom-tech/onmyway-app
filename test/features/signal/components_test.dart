// 신호 전용 컴포넌트 (design-guide 4-2, D-073)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onmyway/core/theme/app_theme.dart';
import 'package:onmyway/features/signal/domain/signal_timer.dart';
import 'package:onmyway/features/signal/ui/components/signal_components.dart';

void main() {
  // 녹색 15초 남음, G = 30 → 바 50%
  const live = LiveSignal(cycle: 120, green: 30, phase: 0, now: _at15);

  Future<void> pump(WidgetTester t, Widget w, {bool reduceMotion = true}) => t.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(data: MediaQueryData(disableAnimations: reduceMotion), child: Scaffold(body: w)),
      ));

  testWidgets('Countdown: 진행 바는 남은 비율만큼, 오른쪽에 붙어 줄어든다 (D-076)', (t) async {
    await pump(t, const Countdown(live: live, spokenTrust: '내 기록'));
    final track = find.descendant(of: find.byType(SignalBar), matching: find.byType(LayoutBuilder));
    final fill = find.descendant(of: track, matching: find.byType(ColoredBox));
    expect(t.getTopRight(fill).dx, t.getTopRight(track).dx);
    expect(t.getSize(fill).width, closeTo(t.getSize(track).width / 2, 0.5));
  });

  testWidgets('Countdown: 매 프레임 다시 계산해 바가 부드럽게 줄어든다 (D-076)', (t) async {
    var clock = 15.0;
    await pump(t, Countdown(live: LiveSignal(cycle: 120, green: 30, phase: 0, now: () => clock), spokenTrust: ''), reduceMotion: false);
    final track = find.descendant(of: find.byType(SignalBar), matching: find.byType(LayoutBuilder));
    final fill = find.descendant(of: track, matching: find.byType(ColoredBox));
    final w0 = t.getSize(fill).width;
    clock = 15.25; // 1초 안 됨 — 숫자는 그대로, 바는 줄어든다
    await t.pump(const Duration(milliseconds: 16));
    expect(t.getSize(fill).width, lessThan(w0));
    expect(find.text('15초'), findsOneWidget);
  });

  testWidgets('SignalBadge: 상태 라벨을 글자로 보여준다 — 녹색은 끝까지 "녹색"', (t) async {
    await pump(t, const SignalBadge(SignalState.green));
    expect(find.text('녹색'), findsOneWidget);
  });
}

double _at15() => 15;
