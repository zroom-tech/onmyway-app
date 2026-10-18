import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onmyway/app/app.dart';
import 'package:onmyway/core/theme/signal_colors.dart';
import 'package:onmyway/core/theme/tokens.g.dart';
import 'package:onmyway/features/signal/data/local_db.dart';

void main() {
  Future<void> launch(WidgetTester tester) async {
    final db = LocalDb(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox()); // 화면을 먼저 내려 1초 타이머·DB 구독을 정리
      await db.close();
    });
    await tester.pumpWidget(ProviderScope(overrides: [localDbProvider.overrideWithValue(db)], child: const OnmywayApp()));
    await tester.pump();
  }

  testWidgets('첫 실행: 신호등 탭 + 두 갈래 안내, 팝업 없음 (traffic-signal D-055·D-056)', (tester) async {
    await launch(tester);

    expect(find.bySemanticsLabel('신호등 탭'), findsOneWidget);
    expect(find.bySemanticsLabel('동네 탭'), findsOneWidget);
    expect(find.bySemanticsLabel('마이 탭'), findsOneWidget);
    expect(find.text('출근길 신호를 모아 볼 수 있어요'), findsOneWidget);
    expect(find.text('로그인하기'), findsOneWidget);
    expect(find.text('지금 기록하기'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('동네 탭은 로그인 전 안내 (D-050)', (tester) async {
    await launch(tester);
    await tester.tap(find.bySemanticsLabel('동네 탭'));
    await tester.pumpAndSettle();
    expect(find.text('로그인하면 동네 신호와 한마디를 볼 수 있어요'), findsOneWidget);
  });

  testWidgets('테마에 신호 색 확장이 등록되어 있다', (tester) async {
    await launch(tester);
    final context = tester.element(find.byType(Scaffold).first);
    final signal = Theme.of(context).extension<SignalColors>();
    expect(signal?.go, TokenColors.signalGo);
    expect(signal?.stop, TokenColors.signalStop);
  });
}
