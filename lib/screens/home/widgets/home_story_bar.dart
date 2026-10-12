import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../room_management/room_management_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// Instagram Stories-styled horizontal status ring bar for real-time dorm updates
class HomeStoryBar extends StatelessWidget {
  const HomeStoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // Story 1: Vacant Rooms (IG Orange-Pink Gradient)
              _buildStoryItem(
                context: context,
                title: 'ห้องว่าง (5)',
                icon: Icons.meeting_room_rounded,
                gradientColors: const [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                hasUpdate: true,
                badgeText: '5 ว่าง',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const RoomManagementScreen()),
                  );
                },
              ),
              const SizedBox(width: 14),

              // Story 2: Urgent Repair (IG Red-Flame Gradient)
              _buildStoryItem(
                context: context,
                title: 'แจ้งซ่อมด่วน',
                icon: CupertinoIcons.wrench_fill,
                gradientColors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                hasUpdate: true,
                badgeText: 'ด่วน 1',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const MaintenanceScreen()),
                  );
                },
              ),
              const SizedBox(width: 14),

              // Story 3: Unpaid Bills (IG Purple-Indigo Gradient)
              _buildStoryItem(
                context: context,
                title: 'รอจ่ายบิล',
                icon: CupertinoIcons.money_dollar,
                gradientColors: const [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                hasUpdate: true,
                badgeText: '3 บิล',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const FinancialReportScreen()),
                  );
                },
              ),
              const SizedBox(width: 14),

              // Story 4: Meter Progress (IG Emerald-Green Gradient)
              _buildStoryItem(
                context: context,
                title: 'จดมิเตอร์',
                icon: CupertinoIcons.bolt_fill,
                gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                hasUpdate: false,
                badgeText: '45/50',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const MeterReadingScreen()),
                  );
                },
              ),
              const SizedBox(width: 14),

              // Story 5: LINE OA (LINE Brand Green Gradient)
              _buildStoryItem(
                context: context,
                title: 'LINE OA',
                icon: CupertinoIcons.chat_bubble_2_fill,
                gradientColors: const [Color(0xFF06C755), Color(0xFF00B900)],
                hasUpdate: false,
                badgeText: '45 ต่อ',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const LineOaScreen()),
                  );
                },
              ),
              const SizedBox(width: 14),

              // Story 6: Tenants List
              _buildStoryItem(
                context: context,
                title: 'ผู้เช่าทั้งหมด',
                icon: CupertinoIcons.person_2_fill,
                gradientColors: const [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                hasUpdate: false,
                badgeText: '45 คน',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const TenantManagementScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required bool hasUpdate,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Story Gradient Circle Ring
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Outer Gradient Ring
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: gradientColors,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5), // Ring thickness
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF6F6F9),
                          gradient: LinearGradient(
                            colors: [
                              gradientColors.first.withAlpha(35),
                              gradientColors.last.withAlpha(20),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: gradientColors.first,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Mini Bottom Pill Badge
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: gradientColors.first,
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

          // Story Label
          SizedBox(
            width: 70,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
