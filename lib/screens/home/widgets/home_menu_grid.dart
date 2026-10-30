import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/custom_icon_badge.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../room_management/room_management_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

class _ModuleItem {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? customIcon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.title,
    required this.subtitle,
    this.icon,
    this.customIcon,
    required this.color,
    required this.onTap,
  });
}

/// Professional Enterprise Core Modules Directory
class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleItem(
        title: 'จัดการห้องพัก',
        subtitle: '50 ยูนิต • ว่าง 5',
        icon: Icons.apartment_rounded,
        color: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const RoomManagementScreen()),
          );
        },
      ),
      _ModuleItem(
        title: 'ผู้เช่าและสัญญา',
        subtitle: '45 สัญญาเช่า',
        icon: CupertinoIcons.person_2_fill,
        color: const Color(0xFF007AFF),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const TenantManagementScreen()),
          );
        },
      ),
      _ModuleItem(
        title: 'จดมิเตอร์น้ำ-ไฟ',
        subtitle: 'รอบ ต.ค. 2026',
        customIcon: 'meter',
        color: const Color(0xFFFF9500),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
          );
        },
      ),
      _ModuleItem(
        title: 'การเงินและบัญชี',
        subtitle: 'รายรับและบิล',
        icon: CupertinoIcons.doc_plaintext,
        color: const Color(0xFF34C759),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
          );
        },
      ),
      _ModuleItem(
        title: 'LINE Official',
        subtitle: '45 บัญชีผู้เช่า',
        customIcon: 'line',
        color: const Color(0xFF06C755),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const LineOaScreen()),
          );
        },
      ),
      _ModuleItem(
        title: 'แจ้งซ่อมบำรุง',
        subtitle: '2 รายการค้าง',
        icon: CupertinoIcons.wrench_fill,
        color: const Color(0xFFFF3B30),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'ศูนย์ระบบงานหลัก',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              '6 โมดูล',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.25,
          ),
          itemBuilder: (context, index) {
            final mod = modules[index];
            return _buildModuleCard(context, mod);
          },
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, _ModuleItem mod) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
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
          highlightColor: mod.color.withAlpha(12),
          onTap: mod.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: mod.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: mod.customIcon != null
                        ? CustomIconBadge(
                            type: mod.customIcon!,
                            size: 19,
                            color: mod.color,
                          )
                        : Icon(
                            mod.icon,
                            size: 18,
                            color: mod.color,
                          ),
                  ),
                ),
                const SizedBox(width: 9),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mod.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        mod.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
