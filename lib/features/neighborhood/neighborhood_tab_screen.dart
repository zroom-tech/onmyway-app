import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/ui/ui.dart';
import '../signal/data/server_signals.dart';
import '../signal/domain/signal_timer.dart';
import '../signal/domain/signal_view.dart';
import '../signal/domain/timer_model.dart';
import '../signal/location/location_gate.dart';
import '../signal/ui/osm_map.dart';
import '../signal/ui/components/crossing_marker.dart';

/// 동네 탭 (traffic-signal D-050): 다른 사람이 등록한 공유 신호 지도 + 가져오기.
/// 출근길 한마디는 commute-gamification(M4). 로그인 전에는 로그인 안내 (FR-01-A-07)
class NeighborhoodTabScreen extends ConsumerStatefulWidget {
  const NeighborhoodTabScreen({super.key});

  @override
  ConsumerState<NeighborhoodTabScreen> createState() => _NeighborhoodTabScreenState();
}

class _NeighborhoodTabScreenState extends ConsumerState<NeighborhoodTabScreen> {
  final _map = MapController();
  List<SignalView> _visible = const [];
  Timer? _debounce;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  // 지도 이동이 끝나면 화면 범위 신호를 다시 받는다 (FR-01-C-01)
  void _onMove(MapCamera camera) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final b = camera.visibleBounds;
      final list = await ref.read(serverSignalsProvider.notifier).loadBounds(b.west, b.south, b.east, b.north);
      if (mounted) setState(() => _visible = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(sessionProvider).loggedIn) {
      return Scaffold(
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(TokenSpace.s5),
            child: Center(child: EmptyState(title: '로그인하면 동네 신호와 한마디를 볼 수 있어요', icon: Icons.map_outlined)),
          ),
        ),
        bottomNavigationBar: BottomAction(children: [Button('로그인하기', onPressed: () => context.go('/my'))]),
      );
    }

    final ss = ref.watch(serverSignalsProvider);
    final now = ss.serverNow();
    return Scaffold(
      body: Stack(children: [
        OsmMap(
          controller: _map,
          onReady: () => _onMove(_map.camera),
          onMove: _onMove,
          layers: [
            MarkerLayer(markers: [
              // 동네 탭 조회는 공유 횡단보도만 — 나만 보기는 위치가 없어 오지 않는다 (D-074)
              for (final v in _visible.where((v) => v.located))
                Marker(
                  point: LatLng(v.midpoint![1], v.midpoint![0]),
                  width: 180,
                  height: 64,
                  child: GestureDetector(
                    onTap: () => context.push('/signal/timer/${v.crosswalkId}?from=neighborhood'),
                    child: CrossingMarker(
                      // 이미 내 신호등이면 구분 표시 (FR-01-D-03)
                      label: ss.mine.contains(v.crosswalkId) ? '${v.displayName} · 내 신호등' : v.displayName,
                      state: _state(v, now),
                    ),
                  ),
                ),
            ]),
          ],
        ),
        if (_visible.isEmpty)
          Positioned(
            left: TokenSpace.s4,
            right: TokenSpace.s4,
            bottom: TokenSpace.s10 + TokenSpace.s4,
            child: MapCard(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('아직 기록이 없어요. 첫 기록을 남겨 보세요', style: TokenTypography.body1.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w600)), // FR-01-B-06
                const SizedBox(height: TokenSpace.s3),
                Button.secondary('횡단보도 등록', onPressed: () => context.push('/signal/register')),
              ]),
            ),
          ),
        Positioned(
          right: TokenSpace.s4,
          top: TokenSpace.s4,
          child: SafeArea(
            child: MapButton(
              '내 주변 보기',
              icon: Icons.near_me_rounded,
              onPressed: () async {
                final pos = await ensureLocation(context, action: '동네 탭 내 주변'); // D-055
                if (pos != null) _map.move(LatLng(pos.latitude, pos.longitude), 17);
              },
            ),
          ),
        ),
      ]),
    );
  }

  SignalState? _state(SignalView v, double? now) {
    final m = timerModelFromView(v, now: now ?? 0, inMySignals: false);
    if (m.params == null || now == null) return null;
    return computeSignal(cycle: m.params!.cycle, green: m.params!.green, phase: m.params!.phase, now: now).state;
  }
}
