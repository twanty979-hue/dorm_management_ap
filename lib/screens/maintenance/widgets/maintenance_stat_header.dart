import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Stat Summary header for maintenance tickets (Apple iOS widget style)
class MaintenanceStatHeader extends StatelessWidget {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  const MaintenanceStatHeader({
    super.key,
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('ทั้งหมด', '$total', AppColors.textPrimary),
          _buildDivider(),
          _buildStatColumn('รอดำเนินการ', '$pending', AppColors.primary),
          _buildDivider(),
          _buildStatColumn('กำลังทำ', '$inProgress', const Color(0xFF007AFF)),
          _buildDivider(),
          _buildStatColumn('เสร็จสิ้น', '$completed', const Color(0xFF34C759)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 0.8,
      color: Colors.black.withAlpha(15),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: valueColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
