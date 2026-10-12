import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/financial_report_model.dart';

/// Card showing revenue breakdown by category (Rent, Electric, Water, Common fee)
class RevenueBreakdownCard extends StatelessWidget {
  final MonthlyFinancialSummary summary;

  const RevenueBreakdownCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final total = summary.totalRevenue > 0 ? summary.totalRevenue : 1;
    final rentPct = (summary.totalRent / total) * 100;
    final elecPct = (summary.totalElectric / total) * 100;
    final waterPct = (summary.totalWater / total) * 100;
    final commonPct = (summary.totalCommonFee / total) * 100;

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
            children: const [
              Text(
                'สัดส่วนรายรับแยกตามประเภท',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Icon(CupertinoIcons.chart_pie_fill, size: 18, color: AppColors.iconDefault),
            ],
          ),
          const SizedBox(height: 14),

          // Multi-color segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (rentPct * 10).round(),
                    child: Container(color: AppColors.primary),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (elecPct * 10).round(),
                    child: Container(color: const Color(0xFFD47C38)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (waterPct * 10).round(),
                    child: Container(color: const Color(0xFF007AFF)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (commonPct * 10).round(),
                    child: Container(color: const Color(0xFF5856D6)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category List Rows
          _buildCategoryRow(
            'ค่าเช่าห้องพัก',
            summary.totalRent,
            rentPct,
            AppColors.primary,
            CupertinoIcons.house_fill,
          ),
          const Divider(height: 14, thickness: 0.5),
          _buildCategoryRow(
            'ค่าไฟฟ้า',
            summary.totalElectric,
            elecPct,
            const Color(0xFFD47C38),
            CupertinoIcons.bolt_fill,
          ),
          const Divider(height: 14, thickness: 0.5),
          _buildCategoryRow(
            'ค่าน้ำประปา',
            summary.totalWater,
            waterPct,
            const Color(0xFF007AFF),
            CupertinoIcons.drop_fill,
          ),
          const Divider(height: 14, thickness: 0.5),
          _buildCategoryRow(
            'ค่าบริการส่วนกลาง/เน็ต',
            summary.totalCommonFee,
            commonPct,
            const Color(0xFF5856D6),
            CupertinoIcons.wifi,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String title,
    double amount,
    double percent,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '฿${_formatCurrency(amount)}',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
