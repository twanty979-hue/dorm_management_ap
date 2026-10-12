import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hexagonal icon logo matching the top-left header of the app
class HexLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const HexLogo({
    super.key,
    this.size = 48,
    this.backgroundColor = const Color(0xFF676E79),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HexagonPainter(backgroundColor),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            Icons.apartment_rounded,
            size: size * 0.58,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;

  _HexagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = math.min(width, height) / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw subtle gradient / shadow overlay
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) =>
      oldDelegate.color != color;
}
