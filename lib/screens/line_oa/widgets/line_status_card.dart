import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card showing LINE OA connection status, channel details and message quota
class LineStatusCard extends StatelessWidget {
  final int totalQuota;
  final int usedQuota;
  final int connectedTenants;
  final int totalTenants;

  const LineStatusCard({
    super.key,
    this.totalQuota = 500,
    this.usedQuota = 168,
    this.connectedTenants = 42,
    this.totalTenants = 45,
  });

  @override
  Widget build(BuildContext context) {
    final remainingQuota = totalQuota - usedQuota;
    final quotaPercent = (usedQuota / totalQuota).clamp(0.0, 1.0);

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Line Badge, Account name and Status
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF06C755), // LINE Official Green
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'LINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The Green Residence OA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@green_dorm • Basic ID',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.checkmark_alt, size: 13, color: Color(0xFF34C759)),
                    SizedBox(width: 4),
                    Text(
                      'เชื่อมต่อแล้ว',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF34C759),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),

          // Message Quota Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'โควต้าข้อความฟรีประจำเดือน',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Prompt',
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: '$remainingQuota',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06C755),
                      ),
                    ),
                    TextSpan(
                      text: ' / $totalQuota ข้อความ',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quotaPercent,
              minHeight: 7,
              backgroundColor: const Color(0xFFF2F2F7),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06C755)),
            ),
          ),
          const SizedBox(height: 14),

          // Stats Sub-Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(CupertinoIcons.person_2_fill, size: 16, color: Color(0xFF636366)),
                    SizedBox(width: 6),
                    Text(
                      'ผู้เช่าที่ผูก LINE OA',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$connectedTenants / $totalTenants ห้อง (${((connectedTenants / totalTenants) * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
