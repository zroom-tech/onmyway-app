import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';
import 'pressable.dart';

/// `ListItem` — 왼쪽 아이콘 + 텍스트 + 오른쪽 부가 정보 (design-guide 4-1).
/// 듀오링고 패턴: 테두리 + 아래 두께감이 있는 둥근 카드. 누를 수 없는 정보 행은 테두리 없이 `bg.subtle` 면 — 버튼처럼 보이지 않게
class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.title, this.subtitle, this.leading, this.trailing, this.onTap, this.semanticsLabel});

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: TokenSpace.s3),
        child: Semantics(
          button: onTap != null,
          label: semanticsLabel,
          child: PressableSurface(
            face: onTap == null ? TokenColors.bgSubtle : TokenColors.bgDefault,
            edge: TokenColors.borderStrong,
            border: onTap == null ? null : TokenColors.borderStrong,
            onTap: onTap,
            child: Row(children: [
              if (leading != null) ...[_LeadingIcon(leading!), const SizedBox(width: TokenSpace.s3)],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TokenTypography.body1.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle!, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
                ]),
              ),
              if (trailing != null) ...[const SizedBox(width: TokenSpace.s3), trailing!]
              else if (onTap != null) const Icon(Icons.chevron_right_rounded, color: TokenColors.textTertiary),
            ]),
          ),
        ),
      );
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: TokenColors.brandSubtle, borderRadius: BorderRadius.circular(TokenRadius.md)),
        child: Icon(icon, color: TokenColors.brandPrimary, size: 22),
      );
}

/// `ChoiceCard` — 여러 개 중 하나를 고르는 선택지 카드 (D-073, 듀오링고 답 선택 패턴).
/// 고르면 파랑 테두리·두께감 + `brand.subtle` 면. 선택은 색만이 아니라 체크 표시로도 보여준다
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.title, this.subtitle, required this.selected, required this.onTap});

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: TokenSpace.s3),
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: selected,
          button: true,
          child: PressableSurface(
            face: selected ? TokenColors.brandSubtle : TokenColors.bgDefault,
            edge: selected ? TokenColors.brandPrimary : TokenColors.borderStrong,
            border: selected ? TokenColors.brandPrimary : TokenColors.borderStrong,
            onTap: onTap,
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    title,
                    style: TokenTypography.body1.copyWith(color: selected ? TokenColors.brandPrimary : TokenColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null) Text(subtitle!, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
                ]),
              ),
              const SizedBox(width: TokenSpace.s3),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: selected ? TokenColors.brandPrimary : TokenColors.borderStrong,
              ),
            ]),
          ),
        ),
      );
}
