import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';

/// 눌리는 두께감이 있는 면 (traffic-signal D-073 — 듀오링고 버튼·카드 패턴).
/// 아래쪽에 [edge] 색 띠(`stroke.edge`)를 두고, 누르면 면이 띠만큼 내려앉는다. 전체 높이는 그대로라 주변이 흔들리지 않는다.
/// [onTap]이 null이면 누를 수 없는 면 — 띠도 없다.
class PressableSurface extends StatefulWidget {
  const PressableSurface({
    super.key,
    required this.face,
    required this.edge,
    required this.child,
    this.border,
    this.onTap,
    this.radius = TokenRadius.lg,
    this.padding = const EdgeInsets.all(TokenSpace.s4),
    this.minHeight = 48,
  });

  final Color face;
  final Color edge;
  final Color? border;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// 터치 영역 최소 48 (design-guide 2장)
  final double minHeight;
  final Widget child;

  @override
  State<PressableSurface> createState() => _PressableSurfaceState();
}

class _PressableSurfaceState extends State<PressableSurface> {
  var _pressed = false;

  void _set(bool v) {
    if (widget.onTap != null && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final edge = enabled ? TokenStroke.edge : 0.0;
    final down = _pressed ? edge : 0.0;
    // 동작 줄이기 설정이면 즉시 바뀐다 (D-073)
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 80);
    final r = BorderRadius.circular(widget.radius);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: CustomPaint(
        painter: edge == 0 ? null : _EdgePainter(color: widget.edge, radius: widget.radius, edge: edge, down: down),
        child: AnimatedContainer(
          duration: duration,
          margin: EdgeInsets.only(top: down, bottom: edge - down),
          constraints: BoxConstraints(minHeight: widget.minHeight),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.face,
            borderRadius: r,
            border: widget.border == null ? null : Border.all(color: widget.border!, width: TokenStroke.line),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// 두께감 띠. 면 뒤 전체에 깔면 면의 곡선·옆선 가장자리(안티에일리어싱 픽셀)에 띠 색이 비쳐 옆선이 지글거린다.
/// 그래서 면과 같은 모양을 아래로 민 둥근 사각을 **면의 아래 모서리 곡선이 시작하는 높이부터만** 그린다 —
/// 그 위로는 면과 겹치는 곳이 없어 옆선이 깨끗하다
class _EdgePainter extends CustomPainter {
  _EdgePainter({required this.color, required this.radius, required this.edge, required this.down});
  final Color color;
  final double radius;
  final double edge;
  final double down;

  @override
  void paint(Canvas canvas, Size size) {
    final faceTop = down;
    final faceBottom = size.height - (edge - down);
    final r = radius.clamp(0.0, (faceBottom - faceTop) / 2);
    final band = RRect.fromRectAndRadius(Rect.fromLTRB(0, faceTop + (edge - down), size.width, size.height), Radius.circular(r));
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, faceBottom - r, size.width, size.height))
      ..drawRRect(band, Paint()..color = color..isAntiAlias = true)
      ..restore();
  }

  @override
  bool shouldRepaint(_EdgePainter old) => old.color != color || old.radius != radius || old.edge != edge || old.down != down;
}
