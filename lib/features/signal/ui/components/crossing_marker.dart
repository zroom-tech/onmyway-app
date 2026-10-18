import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/signal_colors.dart';
import '../../../../core/theme/tokens.g.dart';
import '../../domain/signal_timer.dart';

/// `CrossingMarker` (design-guide 4-2) — 지도 마커. 신호 상태를 색 + 글자 + 모양으로 (FR-01-B-02, design-guide D2). 초 단위 숫자는 없다 (FR-01-B-03).
/// 모양: 녹색 = 원, 적색 = 사각, 정보 없음 = 마름모 (프로토타입 안 D-063, 곧 바뀜 고리는 D-076으로 폐기)
class CrossingMarker extends StatelessWidget {
  const CrossingMarker({super.key, required this.state, required this.label});

  /// null이면 정보 없음
  final SignalState? state;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<SignalColors>()!;
    final onSignal = Theme.of(context).colorScheme.onPrimary;
    final (color, glyph, shape) = switch (state) {
      SignalState.green => (c.go, '녹', _Shape.circle),
      SignalState.red => (c.stop, '적', _Shape.square),
      null => (c.unknown, '—', _Shape.diamond),
    };
    final glyphText = Text(glyph, style: TokenTypography.caption.copyWith(color: onSignal, fontWeight: FontWeight.w700, height: 1));
    Widget body = Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: shape == _Shape.square || shape == _Shape.diamond ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: shape == _Shape.square || shape == _Shape.diamond ? BorderRadius.circular(TokenRadius.sm) : null,
        border: Border.all(color: onSignal, width: 3),
      ),
      child: shape == _Shape.diamond ? Transform.rotate(angle: -math.pi / 4, child: glyphText) : glyphText,
    );
    if (shape == _Shape.diamond) body = Transform.rotate(angle: math.pi / 4, child: body);

    return Semantics(
      label: '$label, ${state?.label ?? '기록 없음'}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          const SizedBox(height: TokenSpace.s1),
          // 지도 위 요소라 그림자 허용 (design-guide 3-4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: TokenSpace.s2, vertical: 2),
            decoration: BoxDecoration(
              color: TokenColors.bgDefault,
              borderRadius: BorderRadius.circular(TokenRadius.sm),
              border: Border.all(color: TokenColors.borderStrong),
            ),
            child: Text(
              label,
              style: TokenTypography.caption.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Shape { circle, square, diamond }
