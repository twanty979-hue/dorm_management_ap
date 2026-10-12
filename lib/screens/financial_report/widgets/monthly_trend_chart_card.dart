import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MonthlyTrendChartCard extends StatelessWidget {
  const MonthlyTrendChartCard({super.key});

  static const List<Map<String, dynamic>> _trendData = [
    {'month': 'มี.ค.', 'revenue': 225.0, 'isCurrent': false},
    {'month': 'เม.ย.', 'revenue': 238.5, 'isCurrent': false},
    {'month': 'พ.ค.', 'revenue': 230.0, 'isCurrent': false},
    {'month': 'มิ.ย.', 'revenue': 242.0, 'isCurrent': false},
    {'month': 'ก.ค.', 'revenue': 245.5, 'isCurrent': false},
    {'month': 'ส.ค.', 'revenue': 248.5, 'isCurrent': true},
  ];

  @override
  Widget build(BuildContext context) {
    const double maxRevenue = 260.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F9EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      color: Color(0xFF34C759),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'แนวโน้มรายรับ 6 เดือนย้อนหลัง',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.arrow_up_right, size: 12, color: Color(0xFF34C759)),
                    SizedBox(width: 2),
                    Text(
                      '+3.8%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF248A3D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bar Chart Visual
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _trendData.map((d) {
                final double rev = d['revenue'] as double;
                final bool isCur = d['isCurrent'] as bool;
                final double barHeight = (rev / maxRevenue) * 90;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${rev.toStringAsFixed(0)}k',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCur ? FontWeight.w800 : FontWeight.w600,
                        color: isCur ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: isCur
                            ? const LinearGradient(
                                colors: [Color(0xFFE2724D), AppColors.primary],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : LinearGradient(
                                colors: [
                                  const Color(0xFFE5E5EA),
                                  const Color(0xFFD1D1D6),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isCur
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(80),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d['month'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCur ? FontWeight.w800 : FontWeight.w500,
                        color: isCur ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
