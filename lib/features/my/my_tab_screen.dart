import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/config.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/ui/ui.dart';
import '../signal/data/local_signal_store.dart';
import '../signal/data/server_signals.dart';

/// 마이 탭 (traffic-signal D-050): 내 기록(F-07) + 계정·설정(F-08). 내 진행 현황은 commute-gamification(M4)
class MyTabScreen extends ConsumerWidget {
  const MyTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final local = ref.watch(localSignalStoreProvider);
    final ss = ref.watch(serverSignalsProvider);
    final serverMine = [for (final id in ss.mine) ss.byId[id]].whereType<Object>().length;
    const empty = EmptyState(title: '아직 기록이 없어요', body: '출근길 횡단보도를 기록해 보세요', icon: Icons.directions_walk_rounded);

    return Scaffold(
      appBar: const NavBar(title: '마이'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(TokenSpace.s5, TokenSpace.s2, TokenSpace.s5, TokenSpace.s8),
        children: [
          const SectionHeader('내 기록', first: true),
          if (!session.loggedIn) ...[
            if (local.isEmpty) empty,
            for (final cw in local)
              ListItem(
                leading: Icons.place_rounded,
                title: cw.name,
                subtitle: '기록 ${cw.records.length}건 · ${cw.located ? '공유 안 됨' : '나만 보기'}',
                trailing: Text('로그인하면\n공유돼요', style: TokenTypography.caption.copyWith(color: TokenColors.textTertiary), textAlign: TextAlign.end), // FR-07-A-06
                onTap: () => context.push('/signal/timer/${cw.id}'),
              ),
          ] else ...[
            for (final id in ss.mine)
              if (ss.byId[id]?.mine != null)
                ListItem(
                  leading: Icons.place_rounded,
                  title: ss.byId[id]!.displayName,
                  subtitle: ss.byId[id]!.isPrivate ? '나만 보기' : (ss.byId[id]!.alias == null ? '이 시간대 내 기록 있음' : ss.byId[id]!.sharedName),
                  // "N명이 봤어요"(FR-07-A-03)는 보류 (traffic-signal D-072)
                  onTap: () => context.push('/signal/timer/$id'),
                ),
            if (serverMine == 0) empty,
          ],
          const SectionHeader('계정·설정'),
          if (session.loggedIn) ...[
            ListItem(leading: Icons.account_circle_outlined, title: '${session.provider == 'apple' ? 'Apple' : 'Google'} 계정으로 로그인했어요'),
            ListItem(leading: Icons.logout_rounded, title: '로그아웃', onTap: () => _logout(ref)),
            ListItem(leading: Icons.person_remove_outlined, title: '탈퇴하기', onTap: () => _withdraw(context, ref)),
          ] else ...[
            Button('Google로 계속하기', onPressed: () => _login(context, ref, 'google')),
            if (AppConfig.useFake || AppConfig.appleLogin) ...[
              const SizedBox(height: TokenSpace.s2),
              Button.secondary('Apple로 계속하기', onPressed: () => _login(context, ref, 'apple')),
            ],
          ],
        ],
      ),
    );
  }

  // 기기 기록 공유 동의는 UploadConsentGate가 맡는다 — 로그인이 어떤 경로로 끝나든 묻는다 (FR-08-D-01)
  Future<void> _login(BuildContext context, WidgetRef ref, String provider) async {
    if (!await ref.read(sessionProvider.notifier).signIn(provider)) return;
    await ref.read(serverSignalsProvider.notifier).refreshMine();
  }

  Future<void> _logout(WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).signOut();
    ref.read(serverSignalsProvider.notifier).clear(); // 계정 기록을 기기에 남기지 않는다 (FR-08-B-01)
    await ref.read(localSignalStoreProvider.notifier).clear();
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final ok = await showAppSheet<bool>(
      context,
      title: '탈퇴할까요?',
      // 탈퇴 후 기록 처리 방식은 법무 회신 대기 (OD-009) — 확정되면 안내 문구를 바꾼다
      body: '계정 정보가 삭제돼요',
      children: (context) => [
        Button('탈퇴하기', onPressed: () => Navigator.pop(context, true)),
        Button.secondary('닫기', onPressed: () => Navigator.pop(context, false)),
      ],
    );
    if (ok == true) await _logout(ref); // 서버 탈퇴 API는 OD-009 확정 후
  }
}
