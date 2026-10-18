import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session.dart';
import '../../../core/theme/tokens.g.dart';
import '../../../core/ui/ui.dart';
import '../data/local_signal_store.dart';
import '../data/server_signals.dart';
import '../domain/signal_view.dart';
import '../domain/timer_model.dart';
import 'components/signal_components.dart';

/// 신호등 탭 (traffic-signal F-01, D-075): 내 신호등 타이머 카드 리스트. 지도는 동네 탭에만 있다.
/// 로그인 전에는 기기에 저장한 내 신호등만 보인다 (FR-01-A-07)
class SignalTabScreen extends ConsumerStatefulWidget {
  const SignalTabScreen({super.key});

  @override
  ConsumerState<SignalTabScreen> createState() => _SignalTabScreenState();
}

class _SignalTabScreenState extends ConsumerState<SignalTabScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // 카드의 남은 초가 1초마다 줄어들게 다시 그린다 (FR-01-B-09)
    var n = 0;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
      if (++n % 60 == 0 && ref.read(sessionProvider).loggedIn) ref.read(serverSignalsProvider.notifier).refreshMine(); // FR-01-C-01
    });
    if (ref.read(sessionProvider).loggedIn) Future.microtask(() => ref.read(serverSignalsProvider.notifier).refreshMine());
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return session.loggedIn ? _buildServer(context) : _buildLocal(context);
  }

  Widget _frame({required List<Widget> children, bool showRegister = true}) => Scaffold(
        appBar: const NavBar(title: '신호등'),
        body: ListView(padding: const EdgeInsets.fromLTRB(TokenSpace.s5, TokenSpace.s2, TokenSpace.s5, TokenSpace.s6), children: children),
        bottomNavigationBar: showRegister
            ? BottomAction(children: [Button.secondary('신호등 등록', icon: Icons.add_rounded, onPressed: () => context.push('/signal/register'))])
            : null,
      );

  // 로그인 전: 기기 기록만 (FR-01-A-07, FR-01-B-08)
  Widget _buildLocal(BuildContext context) {
    final crosswalks = ref.watch(localSignalStoreProvider);
    if (crosswalks.isEmpty) return _frame(showRegister: false, children: const [_FirstRun()]);
    final now = nowEpoch();
    final slot = Slot.of(now);
    final store = ref.read(localSignalStoreProvider.notifier);
    return _frame(children: [
      const Callout(title: '로그인하면 주변 신호를 가져올 수 있어요', body: '지금은 내가 기록한 신호만 보여요', icon: Icons.login_rounded),
      const SizedBox(height: TokenSpace.s4),
      for (final cw in crosswalks)
        _localCard(cw, store.groupButtonMarked(cw.groupId) ? null : store.latestForGroup(cw.groupId, slot), store.groupButtonMarked(cw.groupId), now),
    ]);
  }

  Widget _localCard(LocalCrosswalk cw, LocalRecord? r, bool button, double now) {
    final shared = cw.located ? '공유 안 됨' : '나만 보기';
    return SignalCard(
      name: cw.name,
      subtitle: cw.located ? null : '나만 보기',
      live: r == null ? null : LiveSignal(cycle: r.cycle, green: r.green, phase: r.phase, now: nowEpoch),
      // 버튼식 (검증 전) — 서버와 같은 문구 (FR-02-C-06, D-042)
      status: button ? '버튼식 신호일 수 있어요' : '이 시간대 기록이 없어요',
      freshness: r == null ? '내 기록 · $shared' : '내 기록 · $shared · ${daysAgo(r.at, now)} 기록',
      onTap: () => context.push('/signal/timer/${cw.id}'),
    );
  }

  // 로그인: 내 신호등 (FR-01-B-01, D-050)
  Widget _buildServer(BuildContext context) {
    final ss = ref.watch(serverSignalsProvider);
    final now = ss.serverNow();
    final mine = [for (final id in ss.mine) ss.byId[id]].whereType<SignalView>().toList();
    return _frame(
      showRegister: !(ss.loaded && mine.isEmpty),
      children: [
        if (ss.offline) ...[
          const Callout(title: '연결이 끊겼어요', body: '마지막으로 받은 정보로 보여주고 있어요', icon: Icons.wifi_off_rounded),
          const SizedBox(height: TokenSpace.s4),
        ],
        if (ss.loaded && mine.isEmpty) const _EmptyMine(),
        for (final v in mine) _serverCard(v, now),
      ],
    );
  }

  Widget _serverCard(SignalView v, double? now) {
    final m = timerModelFromView(v, now: now ?? DateTime.now().millisecondsSinceEpoch / 1000, inMySignals: true);
    // 오래됨·정보 없음·만료·버튼식이면 숫자 대신 상태 문구 (D-061). 시각 보정 전이면 숫자를 숨긴다 (FR-02-D-02)
    final status = m.params != null && now == null
        ? '시각을 맞추는 중이에요'
        : m.emptyTitle.isNotEmpty
            ? m.emptyTitle
            : m.notices.firstOrNull?.title ?? '';
    return SignalCard(
      name: m.title,
      subtitle: m.subtitle,
      live: m.params != null && now != null ? LiveSignal(cycle: m.params!.cycle, green: m.params!.green, phase: m.params!.phase, now: () => ref.read(serverSignalsProvider).serverNow() ?? now) : null,
      status: status,
      freshness: m.trust,
      onTap: () => context.push('/signal/timer/${v.crosswalkId}'),
    );
  }
}

/// 로그인했는데 내 신호등이 없을 때 (FR-01-B-06)
class _EmptyMine extends StatelessWidget {
  const _EmptyMine();

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const EmptyState(title: '아직 내 신호등이 없어요', body: '출근길 횡단보도를 동네에서 가져오거나 직접 등록해 보세요', icon: Icons.traffic_rounded),
        const SizedBox(height: TokenSpace.s4),
        Button('동네에서 가져오기', onPressed: () => context.go('/neighborhood')),
        const SizedBox(height: TokenSpace.s2),
        Button.secondary('직접 등록하기', onPressed: () => context.push('/signal/register')),
      ]);
}

/// 첫 실행: 로그인 전 + 기기 기록 없음 (FR-01-B-08, D-056). 팝업·소개 화면 없이 리스트 자리에 안내
class _FirstRun extends StatelessWidget {
  const _FirstRun();

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const EmptyState(title: '출근길 신호를 모아 볼 수 있어요', body: '로그인하면 다른 사람이 등록한 출근길 신호를 가져올 수 있어요', icon: Icons.traffic_rounded),
        const SizedBox(height: TokenSpace.s3),
        Button('로그인하기', onPressed: () => context.go('/my')),
        const SizedBox(height: TokenSpace.s6),
        Text('횡단보도 앞이라면 지금 바로 기록해 볼 수 있어요', style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
        const SizedBox(height: TokenSpace.s2),
        // 기록 진입 = 등록 → 첫 기록 (FR-01-B-08)
        Button.secondary('지금 기록하기', onPressed: () => context.push('/signal/register')),
      ]);
}
