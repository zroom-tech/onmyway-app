import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';
import 'pressable.dart';

/// 지도 위에 뜨는 요소만 흐린 그림자를 쓴다 (design-guide 3-4)
const _mapShadow = [BoxShadow(color: Color(0x1F1A1D23), blurRadius: 16, offset: Offset(0, 4))];

/// `MapCard` — 지도 위 안내 카드 (D-073)
class MapCard extends StatelessWidget {
  const MapCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(TokenSpace.s5),
        decoration: BoxDecoration(color: TokenColors.bgDefault, borderRadius: BorderRadius.circular(TokenRadius.lg), boxShadow: _mapShadow),
        child: child,
      );
}

/// `MapButton` — 지도 위 둥근 버튼 (D-073). 주요 = 파랑, 보조 = 흰 면
class MapButton extends StatelessWidget {
  const MapButton(this.label, {super.key, required this.icon, required this.onPressed, this.primary = false});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? TokenColors.brandOnPrimary : TokenColors.textPrimary;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(TokenRadius.full), boxShadow: _mapShadow),
        child: PressableSurface(
          face: primary ? TokenColors.brandPrimary : TokenColors.bgDefault,
          edge: primary ? TokenColors.brandPrimaryEdge : TokenColors.borderStrong,
          border: primary ? null : TokenColors.borderStrong,
          radius: TokenRadius.full,
          onTap: onPressed,
          padding: const EdgeInsets.symmetric(horizontal: TokenSpace.s4, vertical: TokenSpace.s3),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: primary ? fg : TokenColors.brandPrimary),
            const SizedBox(width: TokenSpace.s2),
            Text(label, style: TokenTypography.body1.copyWith(color: fg, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
