import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/signal_colors.dart';
import '../../../../core/theme/tokens.g.dart';
import '../../../../core/ui/pressable.dart';
import '../../domain/signal_timer.dart';

/// 신호 상태별 색·모양 (design-guide 3-2). 녹색 = 원, 적색 = 사각 (곧 바뀜 고리는 D-076으로 폐기)
(Color, BoxShape) signalLook(BuildContext context, SignalState s) {
  final c = Theme.of(context).extension<SignalColors>()!;
  return switch (s) {
    SignalState.green => (c.go, BoxShape.circle),
    SignalState.red => (c.stop, BoxShape.rectangle),
  };
}

/// 실시간 신호 — 화면이 그릴 때마다 [now]로 다시 계산한다 (D-076: 진행 바를 부드럽게)
class LiveSignal {
  const LiveSignal({required this.cycle, required this.green, required this.phase, required this.now});
  final int cycle;
  final int green;
  final double phase;

  /// 보정된 현재 시각 (epoch 초). 로그인 후에는 서버 시각 (FR-02-D-01)
  final double Function() now;

  SignalNow current() => computeSignal(cycle: cycle, green: green, phase: phase, now: now());
}

/// 매 프레임 [live]를 다시 계산해 그린다. "동작 줄이기" 설정이면 프레임 갱신을 하지 않고
/// 부모가 다시 그릴 때(1초)만 바뀐다 (design-guide 8장)
class LiveSignalBuilder extends StatefulWidget {
  const LiveSignalBuilder({super.key, required this.live, required this.builder});
  final LiveSignal live;
  final Widget Function(BuildContext context, SignalNow signal) builder;

  @override
  State<LiveSignalBuilder> createState() => _LiveSignalBuilderState();
}

class _LiveSignalBuilderState extends State<LiveSignalBuilder> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => setState(() {}));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce && _ticker.isActive) _ticker.stop();
    if (!reduce && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.live.current());
}

/// `SignalBadge` — 신호 상태를 색 + 글자 + 모양으로 (design-guide 4-2, D2). 지시 문구 없음 (D-059)
class SignalBadge extends StatelessWidget {
  const SignalBadge(this.state, {super.key, this.compact = false});
  final SignalState state;

  /// 카드 안에서 쓰는 작은 크기
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, shape) = signalLook(context, state);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? TokenSpace.s3 : TokenSpace.s4, vertical: compact ? TokenSpace.s1 : TokenSpace.s2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(TokenRadius.full)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: TokenColors.brandOnPrimary,
            shape: shape,
            borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(3) : null,
          ),
        ),
        const SizedBox(width: TokenSpace.s2),
        Text(state.label, style: (compact ? TokenTypography.body2 : TokenTypography.body1).copyWith(color: TokenColors.brandOnPrimary, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// `Countdown` — 잔여시간 숫자 + 굵은 진행 바 (design-guide 4-2, FR-02-A). 화면의 주인공.
/// 진행 바는 매 프레임 부드럽게 줄어든다 (D-076). 깜빡임·진동·튀는 애니메이션 없음 (FR-02-B-02, D-073)
class Countdown extends StatelessWidget {
  const Countdown({super.key, required this.live, required this.spokenTrust, this.freshness});
  final LiveSignal live;

  /// 스크린리더용 출처·최신성 (FR-02-A-08)
  final String spokenTrust;

  /// 숫자 바로 아래 출처·최신성 (D3 — `FreshnessLabel`을 Countdown 근처에 항상)
  final String? freshness;

  @override
  Widget build(BuildContext context) => LiveSignalBuilder(
        live: live,
        builder: (context, signal) {
          final (color, _) = signalLook(context, signal.state);
          final caption = signal.state.caption;
          return Semantics(
            label: '${signal.state.label}, $caption ${signal.displaySeconds}초, $spokenTrust', // D-057
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(TokenSpace.s5, TokenSpace.s6, TokenSpace.s5, TokenSpace.s5),
              decoration: BoxDecoration(
                color: TokenColors.bgDefault,
                borderRadius: BorderRadius.circular(TokenRadius.lg),
                border: Border.all(color: TokenColors.borderStrong, width: TokenStroke.line),
              ),
              child: Column(children: [
                SignalBadge(signal.state),
                const SizedBox(height: TokenSpace.s4),
                Text(caption, style: TokenTypography.body1.copyWith(color: TokenColors.textSecondary)),
                Text('${signal.displaySeconds}초', style: AppTheme.countdown.copyWith(color: TokenColors.textPrimary)),
                const SizedBox(height: TokenSpace.s4),
                SignalBar(value: signal.barRatio, color: color),
                if (freshness != null) ...[const SizedBox(height: TokenSpace.s3), FreshnessLabel(freshness!)],
              ]),
            ),
          );
        },
      );
}

/// 굵고 둥근 진행 바 (듀오링고 패턴, D-073). 남은 비율만큼 신호색으로 채운다.
/// 남은 부분을 오른쪽에 붙여, 줄어드는 끝이 왼쪽에서 오른쪽으로 움직인다 (D-076)
class SignalBar extends StatelessWidget {
  const SignalBar({super.key, required this.value, required this.color, this.height = 20});
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(TokenRadius.full),
        // 흰 카드 위라 트랙은 bg.subtle보다 한 단계 진한 border.default
        child: ColoredBox(
          color: TokenColors.borderDefault,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, c) => Align(
                alignment: Alignment.centerRight,
                child: SizedBox(width: c.maxWidth * value.clamp(0.0, 1.0), height: height, child: ColoredBox(color: color)),
              ),
            ),
          ),
        ),
      );
}

/// `FreshnessLabel` — 출처·최신성 (design-guide 4-2, D3)
class FreshnessLabel extends StatelessWidget {
  const FreshnessLabel(this.text, {super.key, this.icon = Icons.schedule_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: TokenColors.textTertiary),
        const SizedBox(width: TokenSpace.s1),
        Flexible(child: Text(text, style: TokenTypography.caption.copyWith(color: TokenColors.textTertiary), textAlign: TextAlign.center)),
      ]);
}

/// `SignalCard` — 신호등 탭 카드 (D-075, FR-01-B-09). 이름 + 신호 상태 + 남은 초 + 진행 바 + 출처·최신성.
/// [live]가 null이면 숫자·바·신호 상태 대신 [status] 문구만 (오래됨·정보 없음·버튼식, D-061)
class SignalCard extends StatelessWidget {
  const SignalCard({super.key, required this.name, this.subtitle, this.live, this.status, required this.freshness, required this.onTap});
  final String name;
  final String? subtitle;
  final LiveSignal? live;
  final String? status;
  final String freshness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = live;
    Widget body(SignalNow? s) {
      // 스크린리더 한 문장 (FR-02-A-08과 같은 순서)
      final spoken = s == null ? '$name, ${status ?? ''}, $freshness' : '$name, ${s.state.label}, ${s.state.caption} ${s.displaySeconds}초, $freshness';
      return Semantics(
        button: true,
        label: spoken,
        excludeSemantics: true,
        child: PressableSurface(
          face: TokenColors.bgDefault,
          edge: TokenColors.borderStrong,
          border: TokenColors.borderStrong,
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TokenTypography.body1.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w700)),
                  if (subtitle != null) Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TokenTypography.caption.copyWith(color: TokenColors.textTertiary)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: TokenColors.textTertiary),
            ]),
            const SizedBox(height: TokenSpace.s3),
            if (s != null) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SignalBadge(s.state, compact: true),
                const Spacer(),
                Text(s.state.caption, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
                const SizedBox(width: TokenSpace.s2),
                // 큰 숫자(type.countdown)는 타이머 화면에만 — 카드는 title1 (D-075, design-guide D1 조건)
                Text('${s.displaySeconds}초', style: TokenTypography.title1.copyWith(color: TokenColors.textPrimary, fontFeatures: const [FontFeature.tabularFigures()])),
              ]),
              const SizedBox(height: TokenSpace.s3),
              SignalBar(value: s.barRatio, color: signalLook(context, s.state).$1, height: 12),
            ] else
              Text(status ?? '', style: TokenTypography.body1.copyWith(color: TokenColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: TokenSpace.s3),
            FreshnessLabel(freshness),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: TokenSpace.s3),
      child: l == null ? body(null) : LiveSignalBuilder(live: l, builder: (context, s) => body(s)),
    );
  }
}
