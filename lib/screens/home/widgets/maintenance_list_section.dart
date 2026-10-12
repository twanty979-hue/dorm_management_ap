import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/maintenance_item.dart';
import '../../maintenance/maintenance_screen.dart';

/// Apple iOS-styled section showing pending and recent repair requests
class MaintenanceListSection extends StatelessWidget {
  final List<MaintenanceItem> items;

  const MaintenanceListSection({
    super.key,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    final list = items.isEmpty ? MaintenanceItem.sampleList : items;

    return Column(
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'รายการแจ้งซ่อมค้าง',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const MaintenanceScreen(),
                  ),
                );
              },
              child: const Text(
                'ดูทั้งหมด',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of maintenance tickets (iOS Inset Grouped)
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildAppleMaintenanceCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildAppleMaintenanceCard(BuildContext context, MaintenanceItem item) {
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
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const MaintenanceScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Wrench Icon Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.wrench_fill,
                    color: Color(0xFF636366),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),

                // Title & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Prompt',
                            color: AppColors.textSecondary,
                            letterSpacing: -0.1,
                          ),
                          children: [
                            const TextSpan(text: 'สถานะ: '),
                            TextSpan(
                              text: item.status.description,
                              style: TextStyle(
                                color: item.isPending
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: item.isPending
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Status Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: item.isPending
                        ? AppColors.statusPendingBg
                        : AppColors.statusDoneBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status.badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.isPending
                          ? AppColors.statusPendingText
                          : AppColors.statusDoneText,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Apple Chevron icon
                const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 14,
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
