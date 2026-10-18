import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session.dart';
import '../../../core/theme/tokens.g.dart';
import '../../../core/ui/ui.dart';
import '../data/local_signal_store.dart';
import '../data/server_signals.dart';
import '../data/signal_repository.dart';
import '../domain/signal_view.dart';
import '../domain/timer_model.dart';
import 'components/signal_components.dart';

/// 신호 타이머 (traffic-signal F-02). [fromNeighborhood]면 동네 탭에서 연 것 — 가져오기 진입 (FR-01-D-02)
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key, required this.crosswalkId, this.fromNeighborhood = false});
  final String crosswalkId;
  final bool fromNeighborhood;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _tick;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {}); // FR-02-A-04
      if (++_seconds % 60 == 0 && ref.read(sessionProvider).loggedIn) ref.read(serverSignalsProvider.notifier).refreshMine(); // 60초 재조회
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

  // ── 로그인 전: 기기 기록 (FR-02-E) ───────────────────────────────
  Widget _buildLocal(BuildContext context) {
    final cw = ref.watch(localSignalStoreProvider).where((c) => c.id == widget.crosswalkId).firstOrNull;
    if (cw == null) return const ScreenScaffold(children: [EmptyState(title: '횡단보도를 찾을 수 없어요')]);
    final now = nowEpoch(); // 기기 시각 그대로 (FR-02-E-04)
    final store = ref.read(localSignalStoreProvider.notifier);
    // 버튼식 표시가 있으면 타이머 없이 안내 — 서버의 "버튼식 (검증 전)"과 같다 (FR-02-C-06, D-042)
    final button = store.groupButtonMarked(cw.groupId);
    final r = button ? null : store.latestForGroup(cw.groupId, Slot.of(now)); // 묶인 횡단보도 기록 함께 (FR-03-D-05)
    return ScreenScaffold(
      title: cw.name,
      actions: [Button('기록하기', onPressed: () => context.push('/signal/record/${cw.id}'))],
      children: [
        if (!cw.located) const Padding(padding: EdgeInsets.only(bottom: TokenSpace.s3), child: FreshnessLabel('나만 보기', icon: Icons.lock_outline_rounded)),
        if (button)
          const EmptyState(title: '버튼식 신호일 수 있어요', icon: Icons.touch_app_rounded)
        else if (r == null)
          const EmptyState(title: '이 시간대 기록이 없어요', body: '기록을 남기면 다른 사람도 볼 수 있어요', icon: Icons.schedule_rounded)
        else
          Countdown(
            live: LiveSignal(cycle: r.cycle, green: r.green, phase: r.phase, now: nowEpoch), // 기기 시각 그대로 (FR-02-E-04)
            spokenTrust: '내 기록, ${daysAgo(r.at, now)} 기록',
            freshness: '내 기록 · ${cw.located ? '공유 안 됨' : '나만 보기'} · ${daysAgo(r.at, now)} 기록',
          ),
        // 위치는 나중에 지정할 수 있다 (FR-03-A-08)
        if (!cw.located) ...[
          const SizedBox(height: TokenSpace.s4),
          Button.text('위치 지정하기', icon: Icons.place_outlined, onPressed: () => context.push('/signal/locate/${cw.id}')),
        ],
      ],
    );
  }

  // ── 로그인: 서버 신호 (FR-02-A~F) ────────────────────────────────
  Widget _buildServer(BuildContext context) {
    final ss = ref.watch(serverSignalsProvider);
    final v = ss.byId[widget.crosswalkId];
    if (v == null) return const Scaffold(appBar: NavBar(), body: Center(child: CircularProgressIndicator()));
    final now = ss.serverNow();
    final m = timerModelFromView(v, now: now ?? DateTime.now().millisecondsSinceEpoch / 1000, inMySignals: ss.mine.contains(v.crosswalkId));
    final repo = ref.read(signalRepositoryProvider);
    final notifier = ref.read(serverSignalsProvider.notifier);

    Future<void> act(Future<void> Function() f, String done) async {
      try {
        await f();
        await notifier.refreshMine();
        if (context.mounted) showToast(context, done);
      } on ApiError catch (e) {
        if (context.mounted) showToast(context, _errorText(e.code));
      }
    }

    final importFirst = m.canImport && widget.fromNeighborhood;
    final record = Button('기록하기', onPressed: () => context.push('/signal/record/${v.crosswalkId}'), variant: importFirst ? ButtonVariant.secondary : ButtonVariant.primary);
    return ScreenScaffold(
      title: m.title,
      actions: [
        // 화면당 주요 행동은 하나 (design-guide 2장): 동네에서 열었으면 가져오기, 아니면 기록하기
        if (importFirst) Button('내 신호등에 가져오기', onPressed: () => act(() => repo.importSignal(v.crosswalkId), '내 신호등에 추가했어요')),
        if (m.canRecord) record,
      ],
      children: [
        if (m.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: TokenSpace.s3),
            child: FreshnessLabel(m.subtitle!, icon: v.isPrivate ? Icons.lock_outline_rounded : Icons.place_outlined),
          ),
        if (m.params != null && now != null)
          Countdown(
            live: LiveSignal(cycle: m.params!.cycle, green: m.params!.green, phase: m.params!.phase, now: () => ss.serverNow() ?? now),
            spokenTrust: m.trust.replaceAll(' · ', ', '),
            freshness: m.trust,
          )
        else if (m.params != null)
          const Callout(title: '시각을 맞추는 중이에요', body: '초 단위 숫자를 잠시 숨겼어요', icon: Icons.sync_rounded) // FR-02-D-02
        else if (m.emptyTitle.isNotEmpty)
          EmptyState(title: m.emptyTitle, body: m.emptyBody, icon: v.buttonType != 'none' ? Icons.touch_app_rounded : Icons.schedule_rounded),
        for (final n in m.notices) Callout(title: n.title, body: n.body, icon: Icons.error_outline_rounded),
        if (m.params == null && m.notices.isNotEmpty) Padding(padding: const EdgeInsets.only(top: TokenSpace.s3), child: FreshnessLabel(m.trust)),
        if (ss.offline) const Callout(title: '연결이 끊겼어요', body: '마지막으로 받은 정보로 보여주고 있어요', icon: Icons.wifi_off_rounded),
        if (m.showSwitch) ...[
          const SizedBox(height: TokenSpace.s4),
          ListItem(
            title: '대표값 보기', // D-053
            subtitle: m.switchOn ? '여러 사람 기록을 모은 값이에요' : '내 기록으로 보는 중이에요',
            trailing: Switch(
              value: m.switchOn,
              onChanged: (on) => act(() => repo.updateSignal(v.crosswalkId, showAggregate: on), on ? '대표값으로 보여드려요' : '내 기록으로 보여드려요'),
            ),
          ),
        ],
        const SizedBox(height: TokenSpace.s4),
        // 나만 보기 → 위치 지정하면 공유 (FR-03-A-08)
        if (v.isPrivate) Button.text('위치 지정하고 공유하기', icon: Icons.place_outlined, onPressed: () => context.push('/signal/locate/${v.crosswalkId}')),
        if (m.canReport) Button.text('신고하기', icon: Icons.flag_outlined, onPressed: () => context.push('/signal/report/${v.crosswalkId}')),
        if (m.inMySignals && !importFirst) ...[
          Button.text(v.alias == null ? '별칭 붙이기' : '별칭 고치기', icon: Icons.edit_outlined, onPressed: () => _aliasSheet(context, v)),
          Button.text('내 신호등에서 빼기', icon: Icons.remove_circle_outline_rounded, onPressed: () => act(() => repo.removeSignal(v.crosswalkId), '내 신호등에서 뺐어요')),
        ],
      ],
    );
  }

  Future<void> _aliasSheet(BuildContext context, SignalView v) async {
    final ctrl = TextEditingController(text: v.alias ?? '');
    final saved = await showAppSheet<String>(
      context,
      title: '나만 보는 이름을 붙여 보세요', // §정책성 문구
      body: '다른 사람에게는 보이지 않아요',
      children: (context) => [
        TextField(controller: ctrl, maxLength: 20, autofocus: true, decoration: const InputDecoration(hintText: '예: 회사 앞')),
        Button('저장하기', onPressed: () => Navigator.pop(context, ctrl.text.trim())),
      ],
    );
    if (saved == null) return;
    final repo = ref.read(signalRepositoryProvider);
    await (saved.isEmpty ? repo.updateSignal(v.crosswalkId, clearAlias: true) : repo.updateSignal(v.crosswalkId, alias: saved));
    await ref.read(serverSignalsProvider.notifier).refreshMine();
  }
}

String _errorText(String code) => switch (code) {
      'already_reported_today' => '이 신호는 오늘 이미 신고했어요',
      'sanctioned' => '지금은 이 기능을 쓸 수 없어요',
      'button_signal' => '버튼을 눌러야 켜지는 신호라 기록하지 않아요',
      'network' => '연결이 끊겼어요. 잠시 후 다시 해 주세요',
      _ => '처리하지 못했어요. 잠시 후 다시 해 주세요',
    };
