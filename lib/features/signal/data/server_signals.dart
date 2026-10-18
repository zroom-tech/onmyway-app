import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/signal_view.dart';
import 'signal_repository.dart';

/// 로그인 사용자의 서버 신호 정보 캐시 (traffic-signal F-01·F-02, D-037).
/// 타이머는 기기에서 계산하고, 서버는 화면 진입·60초마다·내 행동 직후에 다시 받는다 (FR-01-C-01).
class ServerSignals {
  const ServerSignals({this.byId = const {}, this.mine = const {}, this.clockOffset, this.offline = false, this.loaded = false});

  final Map<String, SignalView> byId;
  final Set<String> mine;

  /// 서버 시각 − 기기 시각 (FR-02-D-01). null이면 아직 보정 전 → 초 단위 숫자를 숨긴다 (FR-02-D-02)
  final double? clockOffset;

  /// 마지막 조회 실패 → "연결이 끊겼어요" (FR-01-C-02)
  final bool offline;
  final bool loaded;

  double? serverNow() => clockOffset == null ? null : DateTime.now().millisecondsSinceEpoch / 1000 + clockOffset!;

  ServerSignals copyWith({Map<String, SignalView>? byId, Set<String>? mine, double? clockOffset, bool? offline, bool? loaded}) => ServerSignals(
        byId: byId ?? this.byId,
        mine: mine ?? this.mine,
        clockOffset: clockOffset ?? this.clockOffset,
        offline: offline ?? this.offline,
        loaded: loaded ?? this.loaded,
      );
}

class ServerSignalsNotifier extends Notifier<ServerSignals> {
  @override
  ServerSignals build() => const ServerSignals();

  SignalRepository get _repo => ref.read(signalRepositoryProvider);

  double _offset(double serverTime) => serverTime - DateTime.now().millisecondsSinceEpoch / 1000;

  Future<void> refreshMine() async {
    try {
      final r = await _repo.mySignals();
      state = state.copyWith(
        byId: {...state.byId, for (final s in r.signals) s.crosswalkId: s},
        mine: {for (final s in r.signals) s.crosswalkId},
        clockOffset: _offset(r.serverTime),
        offline: false,
        loaded: true,
      );
    } on ApiError {
      state = state.copyWith(offline: true, loaded: true);
    }
  }

  Future<List<SignalView>> loadBounds(double minLng, double minLat, double maxLng, double maxLat) async {
    try {
      final r = await _repo.inBounds(minLng, minLat, maxLng, maxLat);
      state = state.copyWith(byId: {...state.byId, for (final s in r.signals) s.crosswalkId: s}, clockOffset: _offset(r.serverTime), offline: false);
      return r.signals;
    } on ApiError {
      state = state.copyWith(offline: true);
      return const [];
    }
  }

  /// 로그아웃하면 서버 정보를 남기지 않는다 (FR-08-B-01)
  void clear() => state = const ServerSignals();
}

final serverSignalsProvider = NotifierProvider<ServerSignalsNotifier, ServerSignals>(ServerSignalsNotifier.new);
