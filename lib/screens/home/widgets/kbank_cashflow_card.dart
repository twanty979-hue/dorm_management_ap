import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../financial_report/financial_report_screen.dart';

/// K PLUS-styled Hero Cashflow Card for dormitory monthly billing & collection
class KBankCashflowCard extends StatefulWidget {
  const KBankCashflowCard({super.key});

  @override
  State<KBankCashflowCard> createState() => _KBankCashflowCardState();
}

class _KBankCashflowCardState extends State<KBankCashflowCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E222B),
            Color(0xFF14171E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const FinancialReportScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Account/Dorm Name & Eye Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34C759),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'รอบบิล ต.ค. 2026 • บัญชีหอพัก',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E8E93),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isBalanceVisible = !_isBalanceVisible);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isBalanceVisible
                              ? CupertinoIcons.eye_fill
                              : CupertinoIcons.eye_slash_fill,
                          color: Colors.white.withAlpha(180),
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Middle: Total Billed Amount
                const Text(
                  'ยอดเรียกเก็บเดือนนี้',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFAEC6CF),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _isBalanceVisible ? '฿202,500' : '฿ • • • • • •',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'ดูรายงาน',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE2724D),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          CupertinoIcons.chevron_forward,
                          size: 12,
                          color: Color(0xFFE2724D),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Bottom Divider & Two Metrics (Received vs Unpaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha(18),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Collected
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF34C759),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.check_mark,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'รับแล้ว (42 ห้อง)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E8E93),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _isBalanceVisible ? '฿186,500' : '฿ • • •',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF34C759),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        color: Colors.white.withAlpha(25),
                      ),
                      const SizedBox(width: 12),

                      // Unpaid
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.exclamationmark,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ค้างชำระ (3 ห้อง)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E8E93),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _isBalanceVisible ? '฿16,000' : '฿ • • •',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF453A),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
