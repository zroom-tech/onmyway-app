import 'package:flutter/material.dart';

import '../core/theme/tokens.g.dart';

/// 하단 탭 (traffic-signal D-049·D-068). 듀오링고 하단 탭 패턴을 참고했다 —
/// 글자 없이 둥근 아이콘, 선택 탭은 둥근 사각 타일. 아이콘은 직접 그린다 (듀오링고 자산 미사용, D-022).
class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [('신호등', _TabIcon.signal), ('동네', _TabIcon.neighborhood), ('마이', _TabIcon.my)];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TokenColors.bgDefault,
        border: Border(top: BorderSide(color: TokenColors.borderDefault, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (final (i, (label, icon)) in _items.indexed)
                Expanded(child: _Tab(label: label, icon: icon, selected: i == currentIndex, onTap: () => onTap(i))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final _TabIcon icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : const Duration(milliseconds: 120);
    return Semantics(
      label: '${widget.label} 탭',
      button: true,
      selected: widget.selected,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: duration,
            child: AnimatedContainer(
              duration: duration,
              width: 60,
              height: 52,
              decoration: BoxDecoration(
                color: widget.selected ? TokenColors.brandPrimary.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(TokenRadius.lg),
                border: Border.all(
                  color: widget.selected ? TokenColors.brandPrimary.withValues(alpha: 0.45) : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: CustomPaint(size: const Size(34, 34), painter: _IconPainter(widget.icon)),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TabIcon { signal, neighborhood, my }

/// 둥글고 통통한 2톤 아이콘 — 브랜드 블루 + 옅은 브랜드 블루. 신호등 불빛만 신호색 (D-069)
class _IconPainter extends CustomPainter {
  const _IconPainter(this.icon);
  final _TabIcon icon;

  static final _main = Paint()..color = TokenColors.brandPrimary;
  static final _soft = Paint()..color = TokenColors.brandPrimary.withValues(alpha: 0.28);
  static final _white = Paint()..color = TokenColors.brandOnPrimary;
  static final _visor = Paint()..color = TokenColors.textPrimary.withValues(alpha: 0.55);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    switch (icon) {
      case _TabIcon.signal:
        // 기둥 + 둥근 몸통 + 갓 달린 불빛 3개 (빨강·노랑·초록, D-069)
        canvas.drawRRect(RRect.fromLTRBR(w * .42, h * .7, w * .58, h, Radius.circular(w * .06)), _main); // 기둥
        canvas.drawRRect(RRect.fromLTRBR(w * .28, h * .92, w * .72, h, Radius.circular(w * .05)), _soft); // 받침
        canvas.drawRRect(RRect.fromLTRBR(w * .25, 0, w * .75, h * .76, Radius.circular(w * .2)), _main); // 몸통
        final lights = [TokenColors.signalStop, TokenColors.signalSoon, TokenColors.signalGo];
        for (final (i, color) in lights.indexed) {
          final cy = h * (.15 + i * .23);
          final r = w * .095;
          // 갓: 불빛 위를 덮는 둥근 차양
          canvas.drawArc(Rect.fromCircle(center: Offset(w * .5, cy + r * .3), radius: r * 1.9), 3.25, 2.92, true, _visor);
          canvas.drawCircle(Offset(w * .5, cy + r * .15), r * 1.05, _white);
          canvas.drawCircle(Offset(w * .5, cy + r * .15), r * .8, Paint()..color = color);
        }
      case _TabIcon.neighborhood:
        // 둥근 지붕 집 + 문
        final roof = Path()
          ..moveTo(w * .5, h * .06)
          ..quadraticBezierTo(w * .56, h * .06, w * .62, h * .12)
          ..lineTo(w * .94, h * .42)
          ..quadraticBezierTo(w * .98, h * .5, w * .88, h * .5)
          ..lineTo(w * .12, h * .5)
          ..quadraticBezierTo(w * .02, h * .5, w * .06, h * .42)
          ..lineTo(w * .38, h * .12)
          ..quadraticBezierTo(w * .44, h * .06, w * .5, h * .06)
          ..close();
        canvas.drawRRect(RRect.fromLTRBR(w * .16, h * .38, w * .84, h * .96, Radius.circular(w * .14)), _soft);
        canvas.drawPath(roof, _main);
        canvas.drawRRect(RRect.fromLTRBAndCorners(w * .4, h * .6, w * .6, h * .96, topLeft: Radius.circular(w * .1), topRight: Radius.circular(w * .1)), _main);
      case _TabIcon.my:
        // 둥근 머리 + 어깨 (D-069: 눈·입 없음)
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(w * .1, h * .58, w * .9, h,
              topLeft: Radius.circular(w * .4), topRight: Radius.circular(w * .4), bottomLeft: Radius.circular(w * .12), bottomRight: Radius.circular(w * .12)),
          _soft,
        );
        canvas.drawCircle(Offset(w * .5, h * .32), w * .26, _main);
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.icon != icon;
}
