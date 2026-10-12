import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// 4 Operational Quick Alert Pills
class ManagementStatPills extends StatelessWidget {
  const ManagementStatPills({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPill(
            context: context,
            title: 'สัญญารอต่อ',
            count: '3 ห้อง',
            icon: CupertinoIcons.doc_text_fill,
            color: const Color(0xFFE65100),
            bgColor: const Color(0xFFFFF3E0),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const TenantManagementScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildPill(
            context: context,
            title: 'ค้างจ่ายบิล',
            count: '3 บิล',
            icon: CupertinoIcons.money_dollar_circle_fill,
            color: const Color(0xFFFF3B30),
            bgColor: const Color(0xFFFFECEB),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const FinancialReportScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildPill(
            context: context,
            title: 'มิเตอร์ค้างจด',
            count: '5 ห้อง',
            icon: CupertinoIcons.bolt_fill,
            color: const Color(0xFFFF9500),
            bgColor: const Color(0xFFFFF6E5),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const MeterReadingScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildPill(
            context: context,
            title: 'งานซ่อมค้าง',
            count: '2 งาน',
            icon: CupertinoIcons.wrench_fill,
            color: const Color(0xFF007AFF),
            bgColor: const Color(0xFFEBF3FF),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const MaintenanceScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
