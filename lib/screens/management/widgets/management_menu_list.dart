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

/// Full list of management options with Apple iOS grouped style
class ManagementMenuList extends StatelessWidget {
  const ManagementMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = MenuItemModel.managementListMenus;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final menu = menus[index];
        return _buildAppleMenuItemCard(context, menu);
      },
    );
  }

  Widget _buildAppleMenuItemCard(BuildContext context, MenuItemModel menu) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          highlightColor: Colors.black.withAlpha(10),
          onTap: () {
            if (menu.type == MenuType.roomManagement) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const RoomManagementScreen(),
                ),
              );
            } else if (menu.type == MenuType.meterReading) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const MeterReadingScreen(),
                ),
              );
            } else if (menu.type == MenuType.tenantManagement) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const TenantManagementScreen(),
                ),
              );
            } else if (menu.type == MenuType.lineOa) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const LineOaScreen(),
                ),
              );
            } else if (menu.type == MenuType.financialReport) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const FinancialReportScreen(),
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
                    subtitle: 'ระบบจัดการ ${menu.title}',
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: menu.isCustomIcon
                        ? CustomIconBadge(
                            type: menu.customIconType ?? 'meter',
                            size: 24,
                            color: menu.iconColor ?? AppColors.iconDefault,
                          )
                        : Icon(
                            menu.icon,
                            color: menu.iconColor ?? AppColors.iconDefault,
                            size: 22,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title
                Expanded(
                  child: Text(
                    menu.title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Apple Chevron arrow
                const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: AppColors.chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
