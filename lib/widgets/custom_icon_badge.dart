import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Renders custom icons such as LINE OA badge and Meter reading icon
class CustomIconBadge extends StatelessWidget {
  final String type;
  final double size;
  final Color? color;

  const CustomIconBadge({
    super.key,
    required this.type,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (type == 'line' || type == 'line_color') {
      final isColor = type == 'line_color';
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isColor ? const Color(0xFFC45A34) : (color ?? const Color(0xFF5E6573)),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'LINE',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    } else if (type == 'meter') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: color ?? const Color(0xFF5E6573),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size * 0.16,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    color: color ?? const Color(0xFF5E6573),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: size * 0.15),
                Container(
                  width: size * 0.16,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    color: color ?? const Color(0xFF5E6573),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: size * 0.08),
            Container(
              width: size * 0.5,
              height: 2,
              color: color ?? const Color(0xFF5E6573),
            ),
          ],
        ),
      );
    }

    return Icon(Icons.apps_rounded, size: size, color: color ?? AppColors.iconDefault);
  }
}
