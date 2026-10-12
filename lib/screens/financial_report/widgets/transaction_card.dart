import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/financial_report_model.dart';
import 'bill_detail_modal.dart';

/// Card for single room bill transaction
class TransactionCard extends StatelessWidget {
  final RoomBillRecord record;
  final Function(RoomBillRecord) onUpdate;

  const TransactionCard({
    super.key,
    required this.record,
    required this.onUpdate,
  });

  Color _getStatusColor() {
    switch (record.status) {
      case PaymentStatus.paid:
        return const Color(0xFF34C759);
      case PaymentStatus.pendingVerification:
        return const Color(0xFFFF9500);
      case PaymentStatus.unpaid:
        return const Color(0xFFFF3B30);
    }
  }

  Color _getStatusBgColor() {
    switch (record.status) {
      case PaymentStatus.paid:
        return const Color(0xFFE8F9EE);
      case PaymentStatus.pendingVerification:
        return const Color(0xFFFFF4E5);
      case PaymentStatus.unpaid:
        return const Color(0xFFFFECEB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          highlightColor: Colors.black.withAlpha(10),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => BillDetailModal(
                record: record,
                onUpdate: onUpdate,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Top Row: Room, Name & Status pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ห้อง ${record.roomNumber}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.tenantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        record.status.badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sub Info: Breakdown badges & Total amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ค่าห้อง ฿${_formatCurrency(record.roomRent)}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: Color(0xFFC7C7CC))),
                        const SizedBox(width: 6),
                        Text(
                          'น้ำ-ไฟ ฿${_formatCurrency(record.waterCost + record.electricCost)}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      '฿${_formatCurrency(record.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
