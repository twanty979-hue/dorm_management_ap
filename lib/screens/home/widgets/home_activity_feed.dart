import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// Real-time operations audit feed showing latest property events
class HomeActivityFeed extends StatelessWidget {
  const HomeActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'บันทึกกิจกรรมล่าสุด',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              'Live Feed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
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
          child: Column(
            children: [
              _buildFeedItem(
                context: context,
                icon: CupertinoIcons.checkmark_seal_fill,
                iconColor: const Color(0xFF34C759),
                title: 'ห้อง 201: ชำระค่าเช่าเรียบร้อย',
                subtitle: 'ยอด ฿4,500 • โอนผ่าน PromptPay (ยืนยันสลิปอัตโนมัติ)',
                time: '15 นาทีที่แล้ว',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 54, endIndent: 16, color: Color(0x15000000)),
              _buildFeedItem(
                context: context,
                icon: CupertinoIcons.chat_bubble_fill,
                iconColor: const Color(0xFF06C755),
                title: 'ส่งใบแจ้งหนี้รอบ ต.ค. ผ่าน LINE แล้ว',
                subtitle: 'ระบบส่ง Flex Message ไปยังผู้เช่าทั้งหมด 45 ห้อง',
                time: '1 ชม. ที่แล้ว',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 54, endIndent: 16, color: Color(0x15000000)),
              _buildFeedItem(
                context: context,
                icon: CupertinoIcons.wrench_fill,
                iconColor: const Color(0xFFFF3B30),
                title: 'ห้อง 302: แจ้งซ่อมท่อน้ำรั่ว',
                subtitle: 'สถานะ: รอดำเนินการ • รอช่างเข้าประเมินงาน',
                time: '3 ชม. ที่แล้ว',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 54, endIndent: 16, color: Color(0x15000000)),
              _buildFeedItem(
                context: context,
                icon: CupertinoIcons.doc_checkmark_fill,
                iconColor: const Color(0xFF007AFF),
                title: 'ทำสัญญาเช่าใหม่: ห้อง 105',
                subtitle: 'ผู้เช่า: คุณณภัทร • มัดจำ ฿9,000 • สัญญา 1 ปี',
                time: 'เมื่อวานนี้',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const TenantManagementScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
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
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
