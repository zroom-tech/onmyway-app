import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';

/// `StepBar` — 몇 단계 중 몇 번째인지 굵은 칸으로 (D-073, 듀오링고 진행 바 패턴)
class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.done, required this.total, required this.semanticsLabel});
  final int done;
  final int total;

  /// 예: "3번 중 1번 눌렀어요"
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticsLabel,
        excludeSemantics: true,
        child: Row(children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: TokenSpace.s2),
            Expanded(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: i < done ? TokenColors.brandPrimary : TokenColors.bgSubtle,
                  borderRadius: BorderRadius.circular(TokenRadius.full),
                ),
              ),
            ),
          ],
          const SizedBox(width: TokenSpace.s3),
          Text('$done / $total', style: TokenTypography.body2.copyWith(color: TokenColors.textSecondary, fontWeight: FontWeight.w600)),
        ]),
      );
}
