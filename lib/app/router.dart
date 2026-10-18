import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_nav.dart';

import '../features/my/my_tab_screen.dart';
import '../features/my/upload_consent.dart';
import '../features/neighborhood/neighborhood_tab_screen.dart';
import '../features/signal/ui/record_screen.dart';
import '../features/signal/ui/register_screen.dart';
import '../features/signal/ui/report_screen.dart';
import '../features/signal/ui/signal_tab_screen.dart';
import '../features/signal/ui/timer_screen.dart';

final _root = GlobalKey<NavigatorState>();

/// 하단 탭: 신호등 / 동네 / 마이 (traffic-signal D-049). 첫 화면은 신호등 탭이고, 실행 시 권한·로그인 팝업은 없다 (D-055·D-056)
final router = GoRouter(
  navigatorKey: _root,
  initialLocation: '/signal',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Scaffold(
        body: UploadConsentGate(child: shell),
        bottomNavigationBar: BottomNav(
          currentIndex: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/signal', builder: (_, _) => const SignalTabScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/neighborhood', builder: (_, _) => const NeighborhoodTabScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/my', builder: (_, _) => const MyTabScreen())]),
      ],
    ),
    // 타이머·기록·등록은 탭 위에 전체 화면으로
    GoRoute(
      parentNavigatorKey: _root,
      path: '/signal/timer/:id',
      builder: (_, s) => TimerScreen(crosswalkId: s.pathParameters['id']!, fromNeighborhood: s.uri.queryParameters['from'] == 'neighborhood'),
    ),
    GoRoute(parentNavigatorKey: _root, path: '/signal/report/:id', builder: (_, s) => ReportScreen(crosswalkId: s.pathParameters['id']!)),
    GoRoute(parentNavigatorKey: _root, path: '/signal/record/:id', builder: (_, s) => RecordScreen(crosswalkId: s.pathParameters['id']!)),
    GoRoute(parentNavigatorKey: _root, path: '/signal/record-new', builder: (_, s) => RecordScreen(pending: s.extra! as PendingCrosswalk)),
    GoRoute(parentNavigatorKey: _root, path: '/signal/register', builder: (_, _) => const RegisterScreen()),
    // 나만 보기 신호등에 위치 지정 (traffic-signal FR-03-A-08)
    GoRoute(parentNavigatorKey: _root, path: '/signal/locate/:id', builder: (_, s) => RegisterScreen(locateId: s.pathParameters['id'])),
  ],
);
