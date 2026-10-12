import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../invoice/create_invoice_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../room_management/room_management_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// Grouped Apple iOS Inset Section Card for operations
class OperationsGroupedCard extends StatelessWidget {
  const OperationsGroupedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group 1: ห้องพักและสัญญาเช่า
        _buildGroupHeader('งานห้องพักและสัญญาผู้เช่า'),
        const SizedBox(height: 8),
        _buildGroupContainer([
          _buildItem(
            icon: Icons.apartment_rounded,
            iconColor: AppColors.primary,
            iconBg: const Color(0xFFFBECE5),
            title: 'จัดการผังห้องพักและสถานะ',
            subtitle: '50 ห้อง • ว่าง 5 ห้อง (อัตราเช่า 90%)',
            badge: '50 ห้อง',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const RoomManagementScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildItem(
            icon: CupertinoIcons.person_2_fill,
            iconColor: const Color(0xFF007AFF),
            iconBg: const Color(0xFFEBF3FF),
            title: 'รายชื่อผู้เช่าและสัญญาเช่า',
            subtitle: '45 ผู้เช่า • ใกล้หมดสัญญา 3 สัญญา',
            badge: '45 คน',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const TenantManagementScreen()),
              );
            },
          ),
        ]),
        const SizedBox(height: 20),

        // Group 2: การเงินและรอบบิล
        _buildGroupHeader('การเงิน ออกบิล และมิเตอร์'),
        const SizedBox(height: 8),
        _buildGroupContainer([
          _buildItem(
            icon: CupertinoIcons.doc_text_fill,
            iconColor: const Color(0xFFE65100),
            iconBg: const Color(0xFFFFF3E0),
            title: 'สร้างใบแจ้งหนี้ประจำเดือน',
            subtitle: 'คำนวณค่าน้ำ-ไฟ และออกบิลส่งเข้า LINE',
            badge: 'รอบใหม่',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const CreateInvoiceScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildItem(
            icon: CupertinoIcons.chart_bar_square_fill,
            iconColor: const Color(0xFF34C759),
            iconBg: const Color(0xFFE8F9EE),
            title: 'รายงานการเงินและสลิปโอนเงิน',
            subtitle: 'รายรับ ฿248.5k • อนุมัติสลิปโอนเงิน',
            badge: '฿248.5k',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const FinancialReportScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildItem(
            icon: CupertinoIcons.bolt_fill,
            iconColor: const Color(0xFFFF9500),
            iconBg: const Color(0xFFFFF6E5),
            title: 'บันทึกจดเลขมิเตอร์น้ำ-ไฟ',
            subtitle: 'จดแล้ว 45 ห้อง • ค้างจด 5 ห้อง',
            badge: '45/50',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const MeterReadingScreen()),
              );
            },
          ),
        ]),
        const SizedBox(height: 20),

        // Group 3: การสื่อสารและงานช่าง
        _buildGroupHeader('การสื่อสาร LINE OA และงานช่าง'),
        const SizedBox(height: 8),
        _buildGroupContainer([
          _buildItem(
            icon: CupertinoIcons.chat_bubble_2_fill,
            iconColor: const Color(0xFF06C755),
            iconBg: const Color(0xFFEBF9F0),
            title: 'ศูนย์ข้อความ LINE Official Account',
            subtitle: 'ยิงประกาศ Broadcast, ส่ง Flex Message บิล',
            badge: 'เชื่อมแล้ว',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const LineOaScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildItem(
            icon: CupertinoIcons.wrench_fill,
            iconColor: const Color(0xFFFF3B30),
            iconBg: const Color(0xFFFFECEB),
            title: 'รายการแจ้งซ่อมและมอบหมายช่าง',
            subtitle: 'รอดำเนินการ 2 รายการ (ด่วน 1)',
            badge: '2 งาน',
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const MaintenanceScreen()),
              );
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildGroupHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildGroupContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: AppColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
