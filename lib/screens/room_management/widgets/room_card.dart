import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/room_item.dart';
import 'room_detail_modal.dart';

/// Compact, modern Apple iOS-styled Room Card
class RoomCard extends StatelessWidget {
  final RoomItem room;
  final bool isCompact3Col;

  const RoomCard({
    super.key,
    required this.room,
    this.isCompact3Col = false,
  });

  Color _getStatusColor() {
    if (room.isOccupied) return const Color(0xFF34C759); // Green
    if (room.isVacant) return AppColors.primary; // Terracotta
    return const Color(0xFFFF9500); // Orange maintenance
  }

  Color _getStatusBgColor() {
    if (room.isOccupied) return const Color(0xFFE8F9EE);
    if (room.isVacant) return AppColors.primaryContainer;
    return const Color(0xFFFFF4E5);
  }

  String _formatPrice(int price) {
    final value = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '฿$value';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusBgColor = _getStatusBgColor();

    if (isCompact3Col) {
      // 3-Column Super Compact Grid View
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: room.isVacant
                ? AppColors.primary.withAlpha(40)
                : Colors.black.withAlpha(8),
            width: room.isVacant ? 1.0 : 0.8,
          ),
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
            highlightColor: statusColor.withAlpha(12),
            onTap: () => RoomDetailModal.show(context, room),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Room Number & Status Dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        room.roomNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Tenant name / Vacant label
                  Text(
                    room.isOccupied
                        ? (room.tenantName?.replaceAll('คุณ', '') ?? '-')
                        : room.status.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: room.isOccupied
                          ? AppColors.textSecondary
                          : statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    _formatPrice(room.monthlyPrice),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2-Column Compact Sleek Card View
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: room.isVacant
              ? AppColors.primary.withAlpha(45)
              : Colors.black.withAlpha(8),
          width: room.isVacant ? 1.0 : 0.8,
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
          highlightColor: statusColor.withAlpha(12),
          onTap: () => RoomDetailModal.show(context, room),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: Room number + Status pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      room.roomNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        room.status.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Tenant name or state
                Row(
                  children: [
                    Icon(
                      room.isOccupied
                          ? CupertinoIcons.person_fill
                          : room.isVacant
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.wrench_fill,
                      size: 12,
                      color: room.isOccupied
                          ? AppColors.iconDefault
                          : statusColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        room.isOccupied
                            ? (room.tenantName ?? '-')
                            : room.isVacant
                                ? 'พร้อมเข้าอยู่'
                                : 'แจ้งซ่อม',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: room.isOccupied
                              ? AppColors.textPrimary
                              : statusColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom: Price & Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatPrice(room.monthlyPrice),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'ชั้น ${room.floor}',
                      style: const TextStyle(
                        fontSize: 11,
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
