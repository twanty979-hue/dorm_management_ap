import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card showing current utility rates (electric, water, common fee) with edit button
class UtilityRatesCard extends StatelessWidget {
  final double electricRate;
  final double waterRate;
  final int commonFee;
  final VoidCallback onEditTap;

  const UtilityRatesCard({
    super.key,
    required this.electricRate,
    required this.waterRate,
    required this.commonFee,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(CupertinoIcons.slider_horizontal_3, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'อัตราค่าน้ำ - ค่าไฟ - ค่าบริการ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'แก้ไข',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRateRow(
            icon: CupertinoIcons.bolt_fill,
            iconColor: const Color(0xFFD47C38),
            label: 'ค่าไฟฟ้า',
            value: '฿${electricRate.toStringAsFixed(1)} / หน่วย',
          ),
          const Divider(height: 14, thickness: 0.5),
          _buildRateRow(
            icon: CupertinoIcons.drop_fill,
            iconColor: const Color(0xFF007AFF),
            label: 'ค่าน้ำประปา',
            value: '฿${waterRate.toStringAsFixed(1)} / หน่วย',
          ),
          const Divider(height: 14, thickness: 0.5),
          _buildRateRow(
            icon: CupertinoIcons.wifi,
            iconColor: const Color(0xFF5856D6),
            label: 'ค่าบริการส่วนกลาง / เน็ต',
            value: '฿$commonFee / เดือน',
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
