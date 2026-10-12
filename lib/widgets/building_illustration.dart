import 'package:flutter/material.dart';

/// Modern dormitory building illustration using asset image with vector fallback
class BuildingIllustration extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath;

  const BuildingIllustration({
    super.key,
    this.width = 120,
    this.height = 100,
    this.imagePath = 'assets/images/building_graphic.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _BuildingPainter(),
      ),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFFD6C8BE).withAlpha(120)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.88),
        width: w * 0.85,
        height: h * 0.2,
      ),
      shadowPaint,
    );

    // Left Facade (Warm Terracotta / Brownish-Orange)
    final leftFacadePaint = Paint()..color = const Color(0xFFB8593A);
    final leftFacade = Path()
      ..moveTo(w * 0.25, h * 0.18)
      ..lineTo(w * 0.45, h * 0.12)
      ..lineTo(w * 0.45, h * 0.82)
      ..lineTo(w * 0.25, h * 0.80)
      ..close();
    canvas.drawPath(leftFacade, leftFacadePaint);

    // Left Windows
    final leftWinPaint = Paint()..color = const Color(0xFF42322A);
    for (int r = 0; r < 4; r++) {
      final y = h * (0.28 + r * 0.13);
      final winPath = Path()
        ..moveTo(w * 0.29, y)
        ..lineTo(w * 0.40, y - h * 0.02)
        ..lineTo(w * 0.40, y + h * 0.06)
        ..lineTo(w * 0.29, y + h * 0.07)
        ..close();
      canvas.drawPath(winPath, leftWinPaint);
    }

    // Front / Right Facade (Light Warm Cream / Grey)
    final frontFacadePaint = Paint()..color = const Color(0xFFE4E5E7);
    final frontFacade = Path()
      ..moveTo(w * 0.45, h * 0.12)
      ..lineTo(w * 0.88, h * 0.22)
      ..lineTo(w * 0.88, h * 0.86)
      ..lineTo(w * 0.45, h * 0.82)
      ..close();
    canvas.drawPath(frontFacade, frontFacadePaint);

    // Front Windows & Balconies
    final balconyPaint = Paint()
      ..color = const Color(0xFF888F99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final windowPaint = Paint()..color = const Color(0xFF333B48);

    for (int r = 0; r < 4; r++) {
      final yTop = h * (0.25 + r * 0.14);
      final yBot = yTop + h * 0.09;

      for (int c = 0; c < 3; c++) {
        final xLeft = w * (0.49 + c * 0.12);
        final xRight = xLeft + w * 0.09;

        // Window Glass
        final win = Path()
          ..moveTo(xLeft, yTop + (xLeft - w * 0.45) * 0.2)
          ..lineTo(xRight, yTop + (xRight - w * 0.45) * 0.2)
          ..lineTo(xRight, yBot + (xRight - w * 0.45) * 0.2)
          ..lineTo(xLeft, yBot + (xLeft - w * 0.45) * 0.2)
          ..close();
        canvas.drawPath(win, windowPaint);

        // Balcony Railing
        canvas.drawLine(
          Offset(xLeft - 1, yBot + (xLeft - w * 0.45) * 0.2 - 2),
          Offset(xRight + 1, yBot + (xRight - w * 0.45) * 0.2 - 2),
          balconyPaint,
        );
      }
    }

    // Roof Trim
    final roofPaint = Paint()..color = const Color(0xFF9E543A);
    final roofPath = Path()
      ..moveTo(w * 0.24, h * 0.18)
      ..lineTo(w * 0.45, h * 0.10)
      ..lineTo(w * 0.89, h * 0.21)
      ..lineTo(w * 0.88, h * 0.23)
      ..lineTo(w * 0.45, h * 0.13)
      ..lineTo(w * 0.24, h * 0.19)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Warm Autumn Trees on the sides
    final treeTrunkPaint = Paint()
      ..color = const Color(0xFF7D5947)
      ..strokeWidth = 3.0;
    final treeFoliagePaint1 = Paint()..color = const Color(0xFFDF9B6E);
    final treeFoliagePaint2 = Paint()..color = const Color(0xFFC77748);

    // Left Tree
    canvas.drawLine(Offset(w * 0.18, h * 0.84), Offset(w * 0.18, h * 0.70), treeTrunkPaint);
    canvas.drawCircle(Offset(w * 0.18, h * 0.65), w * 0.08, treeFoliagePaint1);

    // Right Trees
    canvas.drawLine(Offset(w * 0.90, h * 0.86), Offset(w * 0.90, h * 0.72), treeTrunkPaint);
    canvas.drawCircle(Offset(w * 0.90, h * 0.68), w * 0.07, treeFoliagePaint2);
    canvas.drawCircle(Offset(w * 0.96, h * 0.74), w * 0.06, treeFoliagePaint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
