import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../maintenance/maintenance_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';
import '../../room_management/room_management_screen.dart';

/// Ultra-clean 2x2 status counters for dorm owners: Just the key numbers, no percentages, no clutter
class CleanStatusGrid extends StatefulWidget {
  const CleanStatusGrid({super.key});

  @override
  State<CleanStatusGrid> createState() => _CleanStatusGridState();
}

class _CleanStatusGridState extends State<CleanStatusGrid> {
  int _vacantRooms = 5;
  final int _pendingBills = 3;
  final int _pendingMeters = 5;
  int _pendingRepairs = 2;

  @override
  void initState() {
    super.initState();
    _loadLiveStats();
  }

  void _loadLiveStats() async {
    try {
      final rooms = await ApiService.getRooms();
      final tickets = await ApiService.getMaintenanceTickets();

      if (mounted) {
        setState(() {
          if (rooms.isNotEmpty) {
            _vacantRooms = rooms.where((r) => r['status'] == 'vacant' || r['status'] == null).length;
          }
          if (tickets.isNotEmpty) {
            _pendingRepairs = tickets.where((t) => t['status'] == 'pending' || t['status'] == 'in_progress').length;
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สรุปสถานะวันนี้',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 1. Vacant Rooms
            Expanded(
              child: _buildStatusCard(
                icon: Icons.meeting_room_rounded,
                iconColor: const Color(0xFF007AFF),
                count: '$_vacantRooms',
                unit: 'ห้อง',
                title: 'ห้องว่างพร้อมเช่า',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const RoomManagementScreen()),
                  ).then((_) => _loadLiveStats());
                },
              ),
            ),
            const SizedBox(width: 10),

            // 2. Unpaid Bills
            Expanded(
              child: _buildStatusCard(
                icon: CupertinoIcons.doc_text_fill,
                iconColor: const Color(0xFFFF3B30),
                count: '$_pendingBills',
                unit: 'บิล',
                title: 'ค้างจ่ายค่าเช่า',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 3. Pending Meters
            Expanded(
              child: _buildStatusCard(
                icon: CupertinoIcons.bolt_fill,
                iconColor: const Color(0xFFFF9500),
                count: '$_pendingMeters',
                unit: 'ห้อง',
                title: 'รอจดมิเตอร์',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MeterReadingScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // 4. Maintenance
            Expanded(
              child: _buildStatusCard(
                icon: CupertinoIcons.wrench_fill,
                iconColor: const Color(0xFFFF2D55),
                count: '$_pendingRepairs',
                unit: 'รายการ',
                title: 'แจ้งซ่อมค้าง',
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
                  ).then((_) => _loadLiveStats());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String unit,
    required String title,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            count,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
