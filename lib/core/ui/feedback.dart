import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';

/// `EmptyState` — 데이터 없음·권한 없음·오류 (design-guide 4-1). 아이콘 원 + 굵은 제목 + 회색 설명
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.body, this.icon = Icons.info_outline_rounded});
  final String title;
  final String? body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: TokenSpace.s4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: TokenColors.bgSubtle, shape: BoxShape.circle),
            child: Icon(icon, color: TokenColors.textTertiary, size: 28),
          ),
          const SizedBox(height: TokenSpace.s4),
          Text(title, style: TokenTypography.title2.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w700)),
          if (body != null && body!.isNotEmpty) ...[
            const SizedBox(height: TokenSpace.s2),
            Text(body!, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
          ],
        ]),
      );
}

/// `Callout` — 화면 안의 안내 상자 (D-073). `bg.subtle` 면, 굵은 한 줄 + 설명
class Callout extends StatelessWidget {
  const Callout({super.key, required this.title, this.body, this.icon = Icons.info_outline_rounded});
  final String title;
  final String? body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: TokenSpace.s3),
        padding: const EdgeInsets.all(TokenSpace.s4),
        decoration: BoxDecoration(color: TokenColors.bgSubtle, borderRadius: BorderRadius.circular(TokenRadius.lg)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22, color: TokenColors.textSecondary),
          const SizedBox(width: TokenSpace.s3),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TokenTypography.body1.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w600)),
              if (body != null) Text(body!, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
            ]),
          ),
        ]),
      );
}

/// `Toast` — 짧은 결과 안내 (design-guide 4-1)
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// `BottomSheet` — 보조 선택 (design-guide 4-1). 진입 직후 자동으로 띄우지 않는다 (6장).
/// 위 모서리 `radius.lg` + 손잡이. [title]·[body] 아래에 [children]
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  String? body,
  required List<Widget> Function(BuildContext context) children,
  bool dismissible = true,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      builder: (context) => Padding(
        // 손잡이가 없는 시트(닫을 수 없음)는 위 여백을 직접 둔다
        padding: EdgeInsets.fromLTRB(TokenSpace.s5, dismissible ? 0 : TokenSpace.s6, TokenSpace.s5, MediaQuery.viewInsetsOf(context).bottom + TokenSpace.s4),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: TokenTypography.title2.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w700)),
            if (body != null) ...[
              const SizedBox(height: TokenSpace.s2),
              Text(body, style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary)),
            ],
            const SizedBox(height: TokenSpace.s5),
            for (final (i, c) in children(context).indexed) ...[if (i > 0) const SizedBox(height: TokenSpace.s2), c],
          ]),
        ),
      ),
    );
