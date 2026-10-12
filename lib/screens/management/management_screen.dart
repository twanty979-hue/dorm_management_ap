import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/management_stat_pills.dart';
import 'widgets/operations_grouped_card.dart';
import 'widgets/premium_upgrade_banner.dart';
import 'widgets/recent_activity_timeline.dart';

/// Screen 2: Operations & Management Hub with Apple iOS Inset Grouped style
class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 110), // Space for frosted glass bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header with Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ศูนย์จัดการและงานปฏิบัติการ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
                    ),
                    child: const Text(
                      'ส.ค. 2026',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Operational Alert Pills (สัญญารอต่อ, ค้างจ่ายบิล, มิเตอร์ค้างจด, งานซ่อม)
              const ManagementStatPills(),
              const SizedBox(height: 20),

              // Structured Inset Grouped Operations (ไม่ใช่แค่ปุ่มเมนูซ้ำ)
              const OperationsGroupedCard(),
              const SizedBox(height: 22),

              // Recent Activity Timeline Logs
              const RecentActivityTimeline(),
              const SizedBox(height: 22),

              // Premium SaaS Banner
              const PremiumUpgradeBanner(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
