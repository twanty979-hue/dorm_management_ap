import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Receipt breakdown summary card
class InvoiceSummaryCard extends StatelessWidget {
  final int rentPrice;
  final double electricCost;
  final double waterCost;
  final int commonFee;
  final int otherFee;

  const InvoiceSummaryCard({
    super.key,
    required this.rentPrice,
    required this.electricCost,
    required this.waterCost,
    required this.commonFee,
    required this.otherFee,
  });

  double get grandTotal => rentPrice + electricCost + waterCost + commonFee + otherFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'สรุปรายการค่าใช้จ่าย',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'รอชำระเงิน',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildRow('ค่าเช่าห้องพัก', '฿${rentPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
          const SizedBox(height: 8),
          _buildRow('ค่าไฟฟ้า', '฿${electricCost.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildRow('ค่าน้ำประปา', '฿${waterCost.toStringAsFixed(0)}'),
          if (commonFee > 0) ...[
            const SizedBox(height: 8),
            _buildRow('ค่าบริการส่วนกลาง / เน็ต', '฿$commonFee'),
          ],
          if (otherFee > 0) ...[
            const SizedBox(height: 8),
            _buildRow('ค่าบริการอื่นๆ', '฿$otherFee'),
          ],
          const Divider(height: 24),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดรวมสุทธิ',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '฿${grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
