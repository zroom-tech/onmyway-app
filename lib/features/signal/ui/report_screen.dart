import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/ui/ui.dart';
import '../data/server_signals.dart';
import '../data/signal_repository.dart';
import '../location/location_gate.dart';

/// 신고 (traffic-signal F-06). 50m 이내에서만 (D-033). 위치는 기기에서만 확인한다
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.crosswalkId});
  final String crosswalkId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String? _kind;
  bool _sending = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final v = ref.watch(serverSignalsProvider).byId[widget.crosswalkId];
    if (v == null) return const Scaffold(appBar: NavBar(title: '신고하기'));
    // 나만 보기는 신고 대상이 아니다 (D-074) — 타이머에 진입이 없지만 직접 들어온 경우를 막는다
    if (!v.located) return const ScreenScaffold(title: '신고하기', children: [EmptyState(title: '나만 보는 신호등은 신고할 수 없어요')]);

    // 상태에 따라 고를 수 있는 유형이 다르다 (F-06 E-01·E-02)
    final kinds = <(String, String)>[
      if (v.buttonType == 'none' && v.infoLevel != 'expired' && v.infoLevel != 'nodata') ('time_mismatch', '시간이 안 맞아요'),
      if (v.buttonType == 'none') ('not_together', '같이 안 켜져요'),
      ('location_wrong', '위치가 틀려요·신호가 없어졌어요'),
    ];

    if (_done) {
      return ScreenScaffold(
        title: '신고하기',
        actions: [
          Button('다시 기록하기', onPressed: () => context.pushReplacement('/signal/record/${widget.crosswalkId}')),
          Button.text('닫기', onPressed: () => context.pop()),
        ],
        children: const [EmptyState(title: '신고했어요', body: '지금 신호를 다시 기록하면 더 빨리 바로잡혀요', icon: Icons.check_circle_outline_rounded)], // FR-06-A-06
      );
    }
    return ScreenScaffold(
      title: '신고하기',
      actions: [Button('신고하기', onPressed: _kind == null || _sending ? null : () => _send(v.endA!, v.endB!))],
      children: [
        const ScreenHeader('어떤 점이 다른가요?'),
        for (final (k, label) in kinds) ChoiceCard(title: label, selected: _kind == k, onTap: () => setState(() => _kind = k)),
      ],
    );
  }

  Future<void> _send(List<double> a, List<double> b) async {
    setState(() => _sending = true);
    final pos = await ensureLocation(context, action: '신고', needAccuracy: true);
    if (!mounted) return;
    final mid = LatLng((a[1] + b[1]) / 2, (a[0] + b[0]) / 2);
    if (pos == null || const Distance().as(LengthUnit.Meter, LatLng(pos.latitude, pos.longitude), mid) > 50) {
      setState(() => _sending = false);
      if (pos != null) showToast(context, '횡단보도에서 50m 안에서만 신고할 수 있어요');
      return;
    }
    try {
      await ref.read(signalRepositoryProvider).report(widget.crosswalkId, _kind!);
      await ref.read(serverSignalsProvider.notifier).refreshMine();
      if (mounted) setState(() => _done = true);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showToast(context, e.code == 'already_reported_today' ? '이 신호는 오늘 이미 신고했어요. 내일 다시 신고할 수 있어요' : '신고하지 못했어요. 잠시 후 다시 해 주세요');
    }
  }
}
