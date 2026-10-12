import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/menu_item_model.dart';
import '../../../widgets/custom_icon_badge.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../placeholder/subpage_screen.dart';
import '../../room_management/room_management_screen.dart';
import '../../settings/settings_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// 2x3 Grid displaying main actions with luxury Apple iOS squircle styling
class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  Color _getMenuIconBgColor(MenuType type) {
    switch (type) {
      case MenuType.roomManagement:
        return const Color(0xFFFBECE5);
      case MenuType.tenantManagement:
        return const Color(0xFFEBF3FF);
      case MenuType.meterReading:
        return const Color(0xFFFFF6E5);
      case MenuType.financialReport:
        return const Color(0xFFE8F9EE);
      case MenuType.lineOa:
        return const Color(0xFFEBF9F0);
      case MenuType.maintenance:
        return const Color(0xFFFFECEB);
      case MenuType.settings:
        return const Color(0xFFF2F2F7);
    }
  }

  Color _getMenuIconColor(MenuType type) {
    switch (type) {
      case MenuType.roomManagement:
        return AppColors.primary;
      case MenuType.tenantManagement:
        return const Color(0xFF007AFF);
      case MenuType.meterReading:
        return const Color(0xFFFF9500);
      case MenuType.financialReport:
        return const Color(0xFF34C759);
      case MenuType.lineOa:
        return const Color(0xFF06C755);
      case MenuType.maintenance:
        return const Color(0xFFFF3B30);
      case MenuType.settings:
        return const Color(0xFF636366);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menus = MenuItemModel.homeGridMenus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'บริการและฟังก์ชันหลัก',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              '6 เมนู',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menus.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 0.95, // Proportional squircle
          ),
          itemBuilder: (context, index) {
            final menu = menus[index];
            return _buildAppleMenuCard(context, menu);
          },
        ),
      ],
    );
  }

  Widget _buildAppleMenuCard(BuildContext context, MenuItemModel menu) {
    final iconBg = _getMenuIconBgColor(menu.type);
    final iconColor = _getMenuIconColor(menu.type);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: iconColor.withAlpha(12),
          onTap: () {
            if (menu.type == MenuType.roomManagement) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const RoomManagementScreen(),
                ),
              );
            } else if (menu.type == MenuType.tenantManagement) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const TenantManagementScreen(),
                ),
              );
            } else if (menu.type == MenuType.meterReading) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const MeterReadingScreen(),
                ),
              );
            } else if (menu.type == MenuType.financialReport) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const FinancialReportScreen(),
                ),
              );
            } else if (menu.type == MenuType.lineOa) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const LineOaScreen(),
                ),
              );
            } else if (menu.type == MenuType.maintenance) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const MaintenanceScreen(),
                ),
              );
            } else if (menu.type == MenuType.settings) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            } else {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SubpageScreen(
                    title: menu.title,
                    subtitle: 'ฟังก์ชัน ${menu.title} สำหรับบริหารจัดการหอพัก',
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with subtle soft circle background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: menu.isCustomIcon
                        ? CustomIconBadge(
                            type: menu.customIconType ?? 'meter',
                            size: 24,
                            color: iconColor,
                          )
                        : Icon(
                            menu.icon,
                            size: 22,
                            color: iconColor,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menu.title,
                  textAlign: TextAlign.center,
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
