// 공통 컴포넌트 (design-guide 4-3, traffic-signal D-073)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onmyway/core/theme/app_theme.dart';
import 'package:onmyway/core/ui/ui.dart';

Widget _wrap(Widget child, {bool reduceMotion = false}) => MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [child]))),
      ),
    );

void main() {
  testWidgets('Button: 누르면 동작하고, onPressed가 없으면 비활성으로 읽힌다', (t) async {
    var n = 0;
    await t.pumpWidget(_wrap(Button('기록하기', onPressed: () => n++)));
    await t.tap(find.text('기록하기'));
    expect(n, 1);

    await t.pumpWidget(_wrap(const Button('다음', onPressed: null)));
    expect(t.widget<PressableSurface>(find.byType(PressableSurface)).onTap, isNull); // 누를 수 없음 → 두께감도 없음
  });

  testWidgets('Button: 터치 영역 높이 48 이상 (design-guide 2장)', (t) async {
    await t.pumpWidget(_wrap(Button.text('되돌리기', onPressed: () {})));
    expect(t.getSize(find.byType(Button)).height, greaterThanOrEqualTo(48));
    await t.pumpWidget(_wrap(Button('기록하기', onPressed: () {})));
    expect(t.getSize(find.byType(Button)).height, greaterThanOrEqualTo(52));
  });

  testWidgets('PressableSurface: 눌러도 전체 높이가 그대로다 (주변이 흔들리지 않음)', (t) async {
    await t.pumpWidget(_wrap(Button('기록하기', onPressed: () {}), reduceMotion: true));
    final before = t.getSize(find.byType(PressableSurface)).height;
    final g = await t.startGesture(t.getCenter(find.text('기록하기')));
    await t.pump();
    expect(t.getSize(find.byType(PressableSurface)).height, before);
    await g.up();
  });

  testWidgets('ChoiceCard: 선택 상태를 체크 표시로도 보여준다 (색만으로 전달하지 않음)', (t) async {
    await t.pumpWidget(_wrap(ChoiceCard(title: '전방향 동시 보행', selected: true, onTap: () {})));
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await t.pumpWidget(_wrap(ChoiceCard(title: '전방향 동시 보행', selected: false, onTap: () {})));
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
  });
}
