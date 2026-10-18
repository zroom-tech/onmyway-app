import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';
import 'pressable.dart';

enum ButtonVariant { primary, secondary, text }

/// `Button` (design-guide 4-1·4-3). 주요 = 파랑 면 + 진한 파랑 두께감, 보조 = 흰 면 + 회색 테두리·두께감, 텍스트 = 면 없음.
/// 높이 52(+두께감 4), 모서리 `radius.lg`, 글자 `type.button`. 화면당 주요 버튼은 하나 (design-guide 2장)
class Button extends StatelessWidget {
  const Button(this.label, {super.key, required this.onPressed, this.variant = ButtonVariant.primary, this.icon});

  const Button.secondary(this.label, {super.key, required this.onPressed, this.icon}) : variant = ButtonVariant.secondary;

  const Button.text(this.label, {super.key, required this.onPressed, this.icon}) : variant = ButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    if (variant == ButtonVariant.text) {
      return Semantics(
        button: true,
        enabled: enabled,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TokenRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(child: _label(enabled ? TokenColors.brandPrimary : TokenColors.textTertiary)),
          ),
        ),
      );
    }

    final primary = variant == ButtonVariant.primary;
    final (face, edge, border, text) = switch ((enabled, primary)) {
      (false, _) => (TokenColors.bgSubtle, TokenColors.borderDefault, TokenColors.borderDefault, TokenColors.textTertiary),
      (true, true) => (TokenColors.brandPrimary, TokenColors.brandPrimaryEdge, null, TokenColors.brandOnPrimary),
      (true, false) => (TokenColors.bgDefault, TokenColors.borderStrong, TokenColors.borderStrong, TokenColors.brandPrimary),
    };
    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      label: label,
      child: PressableSurface(
        face: face,
        edge: edge,
        border: border,
        onTap: onPressed,
        minHeight: 52,
        padding: const EdgeInsets.symmetric(horizontal: TokenSpace.s4, vertical: TokenSpace.s3),
        child: Center(child: _label(text)),
      ),
    );
  }

  Widget _label(Color color) {
    final text = Text(label, textAlign: TextAlign.center, style: TokenTypography.button.copyWith(color: color));
    if (icon == null) return text;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: TokenSpace.s2),
      Flexible(child: text),
    ]);
  }
}
