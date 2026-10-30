import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../invoice/create_invoice_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// Professional Operations Command Bar for fast administrative workflow
class HomeCommandBar extends StatelessWidget {
  const HomeCommandBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'คำสั่งด่วนผู้จัดการ',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildCommandTile(
                context: context,
                label: 'ออกบิลใหม่',
                badgeText: 'รอบ ต.ค.',
                icon: CupertinoIcons.doc_text_fill,
                accentColor: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const CreateInvoiceScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCommandTile(
                context: context,
                label: 'จดมิเตอร์',
                badgeText: 'รอจด 5',
                icon: CupertinoIcons.bolt_fill,
                accentColor: const Color(0xFF007AFF),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCommandTile(
                context: context,
                label: 'แจ้งซ่อมด่วน',
                badgeText: 'ด่วน 1',
                icon: CupertinoIcons.wrench_fill,
                accentColor: const Color(0xFFFF3B30),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCommandTile(
                context: context,
                label: 'บรอดแคสต์',
                badgeText: 'LINE OA',
                icon: CupertinoIcons.chat_bubble_2_fill,
                accentColor: const Color(0xFF06C755),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const LineOaScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCommandTile(
                context: context,
                label: 'รับผู้เช่าเข้า',
                badgeText: '+สัญญา',
                icon: CupertinoIcons.person_badge_plus_fill,
                accentColor: const Color(0xFF5856D6),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const TenantManagementScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCommandTile(
                context: context,
                label: 'สรุปการเงิน',
                badgeText: 'ภาพรวม',
                icon: CupertinoIcons.chart_pie_fill,
                accentColor: const Color(0xFF34C759),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommandTile({
    required BuildContext context,
    required String label,
    required String badgeText,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 106,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withAlpha(9),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          highlightColor: accentColor.withAlpha(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: accentColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
