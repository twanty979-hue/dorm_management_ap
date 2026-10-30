import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/custom_icon_badge.dart';
import '../../invoice/create_invoice_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../room_management/room_management_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

class _CleanMenuItem {
  final String title;
  final String hint;
  final IconData? icon;
  final String? customIcon;
  final Color color;
  final VoidCallback onTap;

  const _CleanMenuItem({
    required this.title,
    required this.hint,
    this.icon,
    this.customIcon,
    required this.color,
    required this.onTap,
  });
}

/// Symmetrical, patterned 2x3 grid with prominent icons for effortless dorm management
class CleanMenuGrid extends StatelessWidget {
  const CleanMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _CleanMenuItem(
        title: 'จัดการห้องพัก',
        hint: 'ดูสถานะห้องทั้งหมด',
        icon: Icons.apartment_rounded,
        color: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const RoomManagementScreen()),
          );
        },
      ),
      _CleanMenuItem(
        title: 'จัดการผู้เช่า',
        hint: 'ข้อมูลผู้เช่า & สัญญา',
        icon: CupertinoIcons.person_2_fill,
        color: const Color(0xFF007AFF),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const TenantManagementScreen()),
          );
        },
      ),
      _CleanMenuItem(
        title: 'จดเลขมิเตอร์',
        hint: 'บันทึกค่าน้ำ-ค่าไฟ',
        customIcon: 'meter',
        color: const Color(0xFFFF9500),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
          );
        },
      ),
      _CleanMenuItem(
        title: 'ออกใบแจ้งหนี้',
        hint: 'คำนวณบิลส่งผู้เช่า',
        icon: CupertinoIcons.doc_text_fill,
        color: const Color(0xFF34C759),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const CreateInvoiceScreen()),
          );
        },
      ),
      _CleanMenuItem(
        title: 'รายการแจ้งซ่อม',
        hint: 'ติดตามงานช่าง',
        icon: CupertinoIcons.wrench_fill,
        color: const Color(0xFFFF2D55),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
          );
        },
      ),
      _CleanMenuItem(
        title: 'ข้อความ LINE OA',
        hint: 'แจ้งเตือน & ประกาศ',
        customIcon: 'line',
        color: const Color(0xFF06C755),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const LineOaScreen()),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เมนูจัดการหอพัก',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45, // Clean, tactile squircle cards
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildPatternCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildPatternCard(BuildContext context, _CleanMenuItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          highlightColor: item.color.withAlpha(12),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: Icon + Subtle Chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.color.withAlpha(18),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: item.customIcon != null
                            ? CustomIconBadge(
                                type: item.customIcon!,
                                size: 22,
                                color: item.color,
                              )
                            : Icon(
                                item.icon,
                                size: 22,
                                color: item.color,
                              ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      size: 14,
                      color: AppColors.chevron.withAlpha(150),
                    ),
                  ],
                ),

                // Bottom: Title & Hint
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
