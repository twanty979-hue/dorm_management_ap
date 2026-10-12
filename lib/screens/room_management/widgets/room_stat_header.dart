import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Compact status summary for the room management screen.
class RoomStatHeader extends StatelessWidget {
  final int total;
  final int occupied;
  final int vacant;
  final int maintenance;

  const RoomStatHeader({
    super.key,
    this.total = 50,
    this.occupied = 45,
    this.vacant = 5,
    this.maintenance = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatPill(
            label: 'ทั้งหมด',
            count: '$total',
            icon: Icons.grid_view_rounded,
            bgColor: Colors.white,
            textColor: AppColors.textPrimary,
            countColor: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            label: 'มีผู้เช่า',
            count: '$occupied',
            icon: Icons.person_outline_rounded,
            bgColor: const Color(0xFFEAF5EC),
            textColor: const Color(0xFF2E7D32),
            countColor: const Color(0xFF1B5E20),
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            label: 'ห้องว่าง',
            count: '$vacant',
            icon: Icons.door_front_door_outlined,
            bgColor: const Color(0xFFFBECE5),
            textColor: AppColors.primary,
            countColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _buildStatPill(
            label: 'แจ้งซ่อม',
            count: '$maintenance',
            icon: Icons.handyman_outlined,
            bgColor: const Color(0xFFFFF3E0),
            textColor: const Color(0xFFE65100),
            countColor: const Color(0xFFEF6C00),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String count,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: textColor.withAlpha(18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: textColor),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: countColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: countColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
