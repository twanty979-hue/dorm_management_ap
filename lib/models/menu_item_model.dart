import 'package:flutter/material.dart';

enum MenuType {
  roomManagement,
  tenantManagement,
  meterReading,
  financialReport,
  lineOa,
  maintenance,
  settings,
}

/// Model for grid/list menu actions
class MenuItemModel {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final MenuType type;
  final bool isCustomIcon;
  final String? customIconType;

  const MenuItemModel({
    required this.title,
    this.icon,
    this.iconColor,
    required this.type,
    this.isCustomIcon = false,
    this.customIconType,
  });

  static List<MenuItemModel> get homeGridMenus => [
        const MenuItemModel(
          title: 'จัดการห้องพัก',
          icon: Icons.home_rounded,
          iconColor: Color(0xFFC45A34),
          type: MenuType.roomManagement,
        ),
        const MenuItemModel(
          title: 'จัดการผู้เช่า',
          icon: Icons.group_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.tenantManagement,
        ),
        const MenuItemModel(
          title: 'จดเลขมิเตอร์',
          type: MenuType.meterReading,
          isCustomIcon: true,
          customIconType: 'meter',
        ),
        const MenuItemModel(
          title: 'รายงานการเงิน',
          icon: Icons.receipt_long_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.financialReport,
        ),
        const MenuItemModel(
          title: 'ข้อความ Line OA',
          type: MenuType.lineOa,
          isCustomIcon: true,
          customIconType: 'line',
        ),
        const MenuItemModel(
          title: 'ตั้งค่า',
          icon: Icons.settings_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.settings,
        ),
      ];

  static List<MenuItemModel> get managementListMenus => [
        const MenuItemModel(
          title: 'จัดการห้องพัก',
          icon: Icons.home_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.roomManagement,
        ),
        const MenuItemModel(
          title: 'จดเลขมิเตอร์',
          type: MenuType.meterReading,
          isCustomIcon: true,
          customIconType: 'meter',
        ),
        const MenuItemModel(
          title: 'ข้อความ Line OA',
          type: MenuType.lineOa,
          isCustomIcon: true,
          customIconType: 'line_color',
        ),
        const MenuItemModel(
          title: 'แจ้งซ่อม',
          icon: Icons.build_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.maintenance,
        ),
        const MenuItemModel(
          title: 'รายงานการเงิน',
          icon: Icons.receipt_long_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.financialReport,
        ),
        const MenuItemModel(
          title: 'ตั้งค่า',
          icon: Icons.settings_rounded,
          iconColor: Color(0xFF5E6573),
          type: MenuType.settings,
        ),
      ];
}
