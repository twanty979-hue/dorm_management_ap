import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Timeline of recent dormitory events & logs
class RecentActivityTimeline extends StatelessWidget {
  const RecentActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'กิจกรรมและการแจ้งเตือนล่าสุด',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'วันนี้',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              _buildActivityItem(
                icon: CupertinoIcons.checkmark_circle_fill,
                iconColor: const Color(0xFF34C759),
                title: 'ห้อง 201 ชำระค่าเช่าเรียบร้อย',
                subtitle: 'ยอด ฿4,800 • โอนผ่านพร้อมเพย์',
                time: '10 นาทีที่แล้ว',
              ),
              const Divider(height: 16, indent: 44),
              _buildActivityItem(
                icon: CupertinoIcons.wrench_fill,
                iconColor: const Color(0xFFFF3B30),
                title: 'ห้อง 104 แจ้งซ่อม: แอร์มีน้ำหยด',
                subtitle: 'ความเร่งด่วน: ด่วน • ผู้แจ้ง คุณวิชัย',
                time: '1 ชม. ที่แล้ว',
              ),
              const Divider(height: 16, indent: 44),
              _buildActivityItem(
                icon: CupertinoIcons.bolt_fill,
                iconColor: const Color(0xFFFF9500),
                title: 'บันทึกจดมิเตอร์ไฟ ชั้น 2 ครบแล้ว',
                subtitle: 'บันทึกโดย คุณณภัทร (ผู้ดูแล)',
                time: '3 ชม. ที่แล้ว',
              ),
              const Divider(height: 16, indent: 44),
              _buildActivityItem(
                icon: CupertinoIcons.person_badge_plus_fill,
                iconColor: const Color(0xFF007AFF),
                title: 'ทำสัญญาเช่าใหม่: ห้อง 105',
                subtitle: 'ผู้เช่า: คุณณภัทร • สัญญา 1 ปี',
                time: 'เมื่อวานนี้',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
