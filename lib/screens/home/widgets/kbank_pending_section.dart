import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../room_management/room_management_screen.dart';
import '../../tenant_management/tenant_management_screen.dart';

/// Banking-styled pending items and room shortcuts for dorm owners
class KBankPendingSection extends StatelessWidget {
  const KBankPendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Unpaid Rooms List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'ห้องค้างชำระรอบนี้',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '3 ห้อง',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const LineOaScreen()),
                );
              },
              child: const Text(
                'ส่งเตือนทั้งหมด',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF06C755),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Unpaid items list container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildUnpaidTile(
                context: context,
                roomNumber: 'ห้อง 204',
                tenantName: 'คุณธีรภัทร',
                amount: '฿4,500',
                overdueText: 'เกิน 3 วัน',
                onRemind: () => _handleRemind(context, '204', 'คุณธีรภัทร'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0x15000000)),
              _buildUnpaidTile(
                context: context,
                roomNumber: 'ห้อง 312',
                tenantName: 'คุณกมลวรรณ',
                amount: '฿4,500',
                overdueText: 'เกิน 2 วัน',
                onRemind: () => _handleRemind(context, '312', 'คุณกมลวรรณ'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0x15000000)),
              _buildUnpaidTile(
                context: context,
                roomNumber: 'ห้อง 405',
                tenantName: 'คุณเอกชัย',
                amount: '฿4,500',
                overdueText: 'เกิน 1 วัน',
                onRemind: () => _handleRemind(context, '405', 'คุณเอกชัย'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section 2: Quick Management Links (All Rooms & Tenants)
        Row(
          children: [
            // Room Management Shortcut
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const RoomManagementScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withAlpha(18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Color(0xFF007AFF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ผังห้องพัก',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'ว่าง 5 / รวม 50',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF34C759),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_forward, size: 14, color: AppColors.chevron),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Tenant Management Shortcut
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const TenantManagementScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5856D6).withAlpha(18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.person_2_fill,
                          color: Color(0xFF5856D6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ข้อมูลผู้เช่า',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              '45 สัญญาเช่า',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_forward, size: 14, color: AppColors.chevron),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnpaidTile({
    required BuildContext context,
    required String roomNumber,
    required String tenantName,
    required String amount,
    required String overdueText,
    required VoidCallback onRemind,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Room Number Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withAlpha(14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              roomNumber,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF3B30),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tenant & Overdue
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenantName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ค้าง $amount • $overdueText',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Send LINE Button
          GestureDetector(
            onTap: onRemind,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF06C755).withAlpha(18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF06C755).withAlpha(50),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    CupertinoIcons.chat_bubble_fill,
                    size: 11,
                    color: Color(0xFF06C755),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'เตือน LINE',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF06C755),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRemind(BuildContext context, String room, String tenant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ส่งข้อความแจ้งเตือนบิลห้อง $room ($tenant) ผ่าน LINE เรียบร้อย'),
        backgroundColor: const Color(0xFF06C755),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
