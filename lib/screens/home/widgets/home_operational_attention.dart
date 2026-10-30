import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';

/// Operational Attention Queue: Urgent tasks requiring management action today
class HomeOperationalAttention extends StatelessWidget {
  const HomeOperationalAttention({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'สิ่งที่ต้องจัดการวันนี้',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '3 งานด่วน',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Text(
              'รอบ ต.ค. 2026',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Urgent Task Cards
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withAlpha(8),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Task 1: Overdue Invoices
              _buildTaskTile(
                context: context,
                icon: CupertinoIcons.exclamationmark_triangle_fill,
                iconColor: const Color(0xFFFF3B30),
                tagText: 'เลยกำหนด 3 วัน',
                tagBg: const Color(0xFFFFECEB),
                tagColor: const Color(0xFFFF3B30),
                title: 'บิลค้างชำระ 3 ห้อง (฿13,500)',
                subtitle: 'ห้อง 204, 312, 405 • ยังไม่ส่งสลิปโอนเงิน',
                actionLabel: 'เตือนผ่าน LINE',
                actionIcon: CupertinoIcons.chat_bubble_fill,
                actionColor: const Color(0xFF06C755),
                onAction: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const LineOaScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x15000000)),

              // Task 2: Urgent Repair Ticket
              _buildTaskTile(
                context: context,
                icon: CupertinoIcons.wrench_fill,
                iconColor: const Color(0xFFFF9500),
                tagText: 'แจ้ง 08:30 น.',
                tagBg: const Color(0xFFFFF6E5),
                tagColor: const Color(0xFFFF9500),
                title: 'ห้อง 302: ท่อน้ำใต้อ่างรั่วซึม',
                subtitle: 'ความเร่งด่วน: สูงมาก • รอช่างตรวจสอบ',
                actionLabel: 'มอบหมายช่าง',
                actionIcon: CupertinoIcons.arrow_right_circle_fill,
                actionColor: const Color(0xFF007AFF),
                onAction: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x15000000)),

              // Task 3: Meter Readings
              _buildTaskTile(
                context: context,
                icon: CupertinoIcons.bolt_fill,
                iconColor: const Color(0xFF007AFF),
                tagText: 'ตัดรอบ 15 ต.ค.',
                tagBg: const Color(0xFFE8F2FF),
                tagColor: const Color(0xFF007AFF),
                title: 'มิเตอร์ไฟค้างจด 5 ห้อง (ชั้น 4-5)',
                subtitle: 'บันทึกให้ครบเพื่อออกใบแจ้งหนี้อัตโนมัติ',
                actionLabel: 'บันทึกมิเตอร์',
                actionIcon: CupertinoIcons.pencil_ellipsis_rectangle,
                actionColor: const Color(0xFF34C759),
                onAction: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String tagText,
    required Color tagBg,
    required Color tagColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData actionIcon,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 12),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top line: Tag + Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tagText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: actionColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: actionColor.withAlpha(45), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(actionIcon, size: 11, color: actionColor),
                            const SizedBox(width: 3.5),
                            Text(
                              actionLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: actionColor,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Title (Full Width, No Truncation)
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

                // Subtitle
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
        ],
      ),
    );
  }
}
