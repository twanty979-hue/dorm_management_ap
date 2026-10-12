import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/maintenance_item.dart';
import 'maintenance_detail_modal.dart';

/// Apple iOS styled maintenance card
class MaintenanceCard extends StatelessWidget {
  final MaintenanceItem item;
  final Function(MaintenanceItem) onUpdate;

  const MaintenanceCard({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  Color _getStatusBgColor() {
    switch (item.status) {
      case MaintenanceStatus.pending:
        return AppColors.statusPendingBg;
      case MaintenanceStatus.inProgress:
        return const Color(0xFF007AFF);
      case MaintenanceStatus.completed:
        return AppColors.statusDoneBg;
      case MaintenanceStatus.cancelled:
        return const Color(0xFFE5E5EA);
    }
  }

  Color _getStatusTextColor() {
    switch (item.status) {
      case MaintenanceStatus.pending:
        return AppColors.statusPendingText;
      case MaintenanceStatus.inProgress:
        return Colors.white;
      case MaintenanceStatus.completed:
        return AppColors.statusDoneText;
      case MaintenanceStatus.cancelled:
        return const Color(0xFF8E8E93);
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} นาทีที่แล้ว';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ชม. ที่แล้ว';
    } else {
      return '${diff.inDays} วันที่แล้ว';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => MaintenanceDetailModal(
                item: item,
                onUpdate: onUpdate,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Room badge, Priority & Status pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ห้อง ${item.roomNumber}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.priority == MaintenancePriority.urgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ด่วนมาก',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status.badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // Bottom Meta: Technician / Cost & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 14,
                          color: AppColors.iconDefault,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.technicianName != null
                              ? 'ช่าง: ${item.technicianName}'
                              : 'ยังไม่มอบหมายช่าง',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: item.technicianName != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: item.technicianName != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(item.reportedAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
