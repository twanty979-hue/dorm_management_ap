import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../invoice/create_invoice_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';

/// 4 Large K PLUS-styled Primary Action Buttons (Issue Bill, Read Meter, LINE Reminder, Repairs)
class KBankQuickActions extends StatelessWidget {
  const KBankQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.doc_text_fill,
            label: 'ออกบิล',
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const CreateInvoiceScreen()),
              );
            },
          ),
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.bolt_fill,
            label: 'จดมิเตอร์',
            badgeText: 'รอ 5',
            color: const Color(0xFFFF9500),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
              );
            },
          ),
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.chat_bubble_2_fill,
            label: 'ตามหนี้ LINE',
            badgeText: '3 บิล',
            color: const Color(0xFF06C755),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const LineOaScreen()),
              );
            },
          ),
          _buildActionButton(
            context: context,
            icon: CupertinoIcons.wrench_fill,
            label: 'แจ้งซ่อม',
            badgeText: '2 งาน',
            color: const Color(0xFFFF3B30),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Circle with soft shadow
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withAlpha(18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 26,
                    color: color,
                  ),
                ),
              ),

              // Micro Badge Pill
              if (badgeText != null)
                Positioned(
                  top: -5,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
