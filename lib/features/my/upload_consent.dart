import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session.dart';
import '../../core/ui/ui.dart';
import '../signal/data/local_signal_store.dart';
import '../signal/data/server_signals.dart';
import '../signal/data/signal_repository.dart';

/// 로그인 상태인데 기기 기록이 남아 있으면 공유 여부를 묻는다 (FR-08-D-01~03).
/// 로그인 버튼 흐름 밖에서 로그인이 끝나도(브라우저 복귀, 앱 재실행) 빠뜨리지 않게 탭 화면 전체를 감싼다
class UploadConsentGate extends ConsumerStatefulWidget {
  const UploadConsentGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<UploadConsentGate> createState() => _UploadConsentGateState();
}

class _UploadConsentGateState extends ConsumerState<UploadConsentGate> {
  var _asking = false;

  /// 이번 실행에서 실패했으면 다시 묻지 않는다 — 다음 실행에 묻는다 (F-08 E-05)
  var _failed = false;

  void _check() {
    if (_asking || _failed || !mounted) return;
    final local = ref.read(localSignalStoreProvider);
    if (!ref.read(sessionProvider).loggedIn || local.isEmpty) return;
    _asking = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _consent(local);
        await ref.read(serverSignalsProvider.notifier).refreshMine();
      } finally {
        _asking = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (_, _) => _check());
    ref.listen(localSignalStoreProvider, (_, _) => _check()); // 기기 DB는 비동기로 열린다
    return widget.child;
  }

  /// 로그인 직후 기기 기록 공유 동의 (FR-08-D-01~03, §정책성 문구)
  Future<void> _consent(List<LocalCrosswalk> local) async {
    final n = local.fold<int>(0, (s, c) => s + c.records.length + (c.buttonMarked ? 1 : 0)); // 버튼식 표시도 1건 (FR-04-D-02)
    final share = await showAppSheet<bool>(
      context,
      dismissible: false,
      title: '기기에 있는 기록 $n건을 공유할까요?',
      body: '공유하면 다른 사람도 이 신호를 볼 수 있어요. 공유하지 않으면 기기에서 지워져요',
      children: (context) => [
        Button('공유하기', onPressed: () => Navigator.pop(context, true)),
        Button.secondary('공유하지 않기', onPressed: () => Navigator.pop(context, false)),
      ],
    );
    final store = ref.read(localSignalStoreProvider.notifier);
    if (share == true) {
      try {
        await ref.read(signalRepositoryProvider).upload([
          for (final c in local)
            UploadItem(
              c.located ? [c.endA!.longitude, c.endA!.latitude] : null,
              c.located ? [c.endB!.longitude, c.endB!.latitude] : null,
              [for (final r in c.records) if (r.taps.length == 3) r.taps],
              group: c.groupId,
              name: c.located ? null : c.name, // 나만 보기는 이름과 함께 (D-074)
              scramble: c.scramble,
              buttonType: c.buttonMarked,
            ),
        ]);
        await store.clear(); // 업로드 완료 후 기기 기록 삭제 (FR-08-D-02)
      } on ApiError {
        // 실패하면 지우지 않고 다음에 다시 묻는다 (F-08 E-05)
        _failed = true;
        if (mounted) showToast(context, '공유하지 못했어요. 다음에 다시 물어볼게요');
      }
    } else {
      await store.clear(); // FR-08-D-03
    }
  }

}
