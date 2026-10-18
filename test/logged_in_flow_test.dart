// 로그인 이후 흐름 (traffic-signal D-047·D-048·D-050·D-053·D-061) — 개발용 가짜 백엔드로 확인
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:onmyway/app/app.dart';
import 'package:onmyway/app/router.dart';
import 'package:onmyway/features/signal/data/local_db.dart';
import 'package:onmyway/features/signal/data/local_signal_store.dart';
import 'package:onmyway/features/signal/data/server_signals.dart';
import 'package:onmyway/features/signal/domain/record_sequence.dart';

void main() {
  late ProviderContainer container;

  Future<void> launch(WidgetTester tester) async {
    final db = LocalDb(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
    router.go('/signal');
    // 흐름 검사라 "동작 줄이기"로 — 진행 바 프레임 갱신(D-076)이 있으면 pumpAndSettle이 끝나지 않는다
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(ProviderScope(overrides: [localDbProvider.overrideWithValue(db)], child: const OnmywayApp()));
    await tester.pump();
    container = ProviderScope.containerOf(tester.element(find.byType(OnmywayApp)));
  }

  Future<void> login(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('마이 탭'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Google로 계속하기'));
    await tester.pumpAndSettle();
  }

  testWidgets('로그인 → 내 신호등 없음 안내 (FR-01-B-06)', (tester) async {
    await launch(tester);
    await login(tester);
    expect(find.text('Google 계정으로 로그인했어요'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('신호등 탭'));
    await tester.pumpAndSettle();
    expect(find.text('아직 내 신호등이 없어요'), findsOneWidget);
    expect(find.text('동네에서 가져오기'), findsOneWidget);
  });

  testWidgets('동네에서 연 타이머 → 가져오기 → 별칭·빼기 진입 (D-050)', (tester) async {
    await launch(tester);
    await login(tester);
    await container.read(serverSignalsProvider.notifier).loadBounds(126.97, 37.56, 126.99, 37.57);
    router.push('/signal/timer/F1?from=neighborhood');
    await tester.pumpAndSettle();
    expect(find.textContaining('확인됨 · 5명 기록'), findsOneWidget);
    expect(find.textContaining('초'), findsWidgets);
    await tester.tap(find.text('내 신호등에 가져오기'));
    await tester.pumpAndSettle();
    expect(find.text('별칭 붙이기'), findsOneWidget);
    expect(find.text('내 신호등에서 빼기'), findsOneWidget);
    expect(container.read(serverSignalsProvider).mine, contains('F1'));
  });

  testWidgets('오래됨은 숫자·상태 숨김 (D-061)', (tester) async {
    await launch(tester);
    await login(tester);
    await container.read(serverSignalsProvider.notifier).loadBounds(126.97, 37.56, 126.99, 37.57);
    router.push('/signal/timer/F2?from=neighborhood');
    await tester.pumpAndSettle();
    expect(find.text('정보가 맞지 않을 수 있어요'), findsOneWidget);
    expect(find.text('녹색'), findsNothing);
    expect(find.text('적색'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('버튼식 신호는 기록 진입 없음 (FR-02-C-06)', (tester) async {
    await launch(tester);
    await login(tester);
    await container.read(serverSignalsProvider.notifier).loadBounds(126.97, 37.56, 126.99, 37.57);
    router.push('/signal/timer/F4?from=neighborhood');
    await tester.pumpAndSettle();
    expect(find.text('버튼을 눌러야 켜지는 신호예요'), findsOneWidget);
    expect(find.text('기록하기'), findsNothing);
  });

  testWidgets('기기 기록이 있으면 로그인 직후 공유 동의 → 공유하면 기기 기록 비움 (FR-08-D)', (tester) async {
    await launch(tester);
    final store = container.read(localSignalStoreProvider.notifier);
    await tester.runAsync(() async {
      await store.ready;
      await store.register(const LatLng(37.5665, 126.978), const LatLng(37.5665, 126.9782), const RecordResult.ok(cycle: 120, green: 30, t0: 1760569200),
          taps: const [Tap(TapKind.green, 1760569200), Tap(TapKind.red, 1760569230), Tap(TapKind.green, 1760569320)]);
    });
    await login(tester);
    expect(find.text('기기에 있는 기록 1건을 공유할까요?'), findsOneWidget);
    await tester.tap(find.text('공유하기'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(container.read(localSignalStoreProvider), isEmpty);
    expect(container.read(serverSignalsProvider).mine, isNotEmpty);
  });

  testWidgets('로그아웃하면 로그인 전 첫 실행으로 (FR-08-B-01)', (tester) async {
    await launch(tester);
    await login(tester);
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('신호등 탭'));
    await tester.pumpAndSettle();
    expect(find.text('출근길 신호를 모아 볼 수 있어요'), findsOneWidget);
  });
}
