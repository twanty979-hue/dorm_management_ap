import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card showing billing cutoff dates and overdue penalty settings
class BillingCycleCard extends StatelessWidget {
  const BillingCycleCard({super.key});

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
            children: const [
              Icon(CupertinoIcons.calendar_badge_plus, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'รอบบิลและกำหนดชำระเงิน',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildItem('วันจดมิเตอร์ / ตัดรอบบิล', 'ทุกวันที่ 25 ของเดือน'),
          const Divider(height: 14, thickness: 0.5),
          _buildItem('วันครบกำหนดชำระเงิน', 'ทุกวันที่ 5 ของเดือนถัดไป'),
          const Divider(height: 14, thickness: 0.5),
          _buildItem('ค่าปรับชำระล่าช้า', '฿50 / วัน (หลังวันที่ 5)'),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
