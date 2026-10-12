import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

enum NotificationType { maintenance, bill, meter, lease }

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isUnread = false,
  });
}

/// Apple iOS 18-styled Notification Center Modal
class NotificationCenterModal extends StatelessWidget {
  const NotificationCenterModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationCenterModal(),
    );
  }

  static const List<NotificationItem> _sampleNotifications = [
    NotificationItem(
      title: 'แจ้งซ่อมด่วน: แอร์ห้อง 204 ไม่เย็น',
      message: 'ผู้เช่าแจ้งว่ามีน้ำหยดจากตัวเครื่องและไม่เย็น ต้องการช่างเข้าตรวจเช็กด่วน',
      time: '10 นาทีที่แล้ว',
      type: NotificationType.maintenance,
      isUnread: true,
    ),
    NotificationItem(
      title: 'บิลค้างชำระ: ห้อง 305 และ 102',
      message: 'เลยกำหนดชำระรอบบิล ส.ค. 2026 แล้ว 3 วัน ระบบเตรียมแจ้งเตือนอัตโนมัติ',
      time: '1 ชั่วโมงที่แล้ว',
      type: NotificationType.bill,
      isUnread: true,
    ),
    NotificationItem(
      title: 'มิเตอร์ค้างจด: เหลือ 5 ห้องบนชั้น 3',
      message: 'จดมิเตอร์น้ำ-ไฟแล้ว 45 จาก 50 ห้อง กรุณาจดให้ครบเพื่อออกใบแจ้งหนี้',
      time: '3 ชั่วโมงที่แล้ว',
      type: NotificationType.meter,
      isUnread: true,
    ),
    NotificationItem(
      title: 'สัญญาใกล้หมด: ห้อง 101 (คุณวิภาดา)',
      message: 'สัญญาเช่า 12 เดือนจะหมดอายุในอีก 20 วัน (30 ก.ย. 2026)',
      time: 'เมื่อวานนี้',
      type: NotificationType.lease,
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.bell_fill,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'การแจ้งเตือน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '3 ใหม่',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withAlpha(8)),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 14,
                      color: AppColors.iconDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0x18000000)),

          // Notifications List
          Flexible(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              itemCount: _sampleNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = _sampleNotifications[index];
                return _buildNotificationCard(context, notif);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    Color iconBg;
    Color iconColor;
    IconData icon;
    VoidCallback? onTapAction;

    switch (item.type) {
      case NotificationType.maintenance:
        iconBg = const Color(0xFFFFECEB);
        iconColor = const Color(0xFFFF3B30);
        icon = CupertinoIcons.wrench_fill;
        onTapAction = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
          );
        };
        break;
      case NotificationType.bill:
        iconBg = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFE65100);
        icon = CupertinoIcons.doc_text_fill;
        onTapAction = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
          );
        };
        break;
      case NotificationType.meter:
        iconBg = const Color(0xFFFFF6E5);
        iconColor = const Color(0xFFFF9500);
        icon = CupertinoIcons.bolt_fill;
        onTapAction = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
          );
        };
        break;
      case NotificationType.lease:
        iconBg = const Color(0xFFEBF3FF);
        iconColor = const Color(0xFF007AFF);
        icon = CupertinoIcons.person_badge_minus_fill;
        onTapAction = () {
          Navigator.pop(context);
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const TenantManagementScreen()),
          );
        };
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: item.isUnread ? const Color(0xFFFAFAFD) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isUnread ? iconColor.withAlpha(45) : Colors.black.withAlpha(8),
          width: item.isUnread ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTapAction,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
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

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'แตะเพื่อเปิดดูรายละเอียด',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 11,
                            color: iconColor,
                          ),
                        ],
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
