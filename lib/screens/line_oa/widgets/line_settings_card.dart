import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Settings card for LINE Developers credentials & Webhook
class LineSettingsCard extends StatelessWidget {
  const LineSettingsCard({super.key});

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
              Icon(CupertinoIcons.gear_alt_fill, size: 18, color: AppColors.iconDefault),
              SizedBox(width: 8),
              Text(
                'การตั้งค่าการเชื่อมต่อ API',
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
          _buildConfigItem('Channel ID', '2001928475'),
          const Divider(height: 14, thickness: 0.5),
          _buildConfigItem('Channel Secret', '••••••••••••••••••••••••••••••••'),
          const Divider(height: 14, thickness: 0.5),
          _buildConfigItem('Webhook URL', 'https://api.greendorm.app/webhook/line'),
          const Divider(height: 14, thickness: 0.5),
          _buildConfigItem('Auto-Reply', 'เปิดใช้งาน (บิล & แจ้งซ่อม)', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String title, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isHighlight ? const Color(0xFF06C755) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
