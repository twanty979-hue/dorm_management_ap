import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/financial_report_model.dart';

/// Modal for viewing bill details, approving payment slip, and sending e-Receipt
class BillDetailModal extends StatefulWidget {
  final RoomBillRecord record;
  final Function(RoomBillRecord) onUpdate;

  const BillDetailModal({
    super.key,
    required this.record,
    required this.onUpdate,
  });

  @override
  State<BillDetailModal> createState() => _BillDetailModalState();
}

class _BillDetailModalState extends State<BillDetailModal> {
  late RoomBillRecord _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  void _approvePayment() {
    final updated = _record.copyWith(
      status: PaymentStatus.paid,
      paidAt: DateTime.now(),
    );
    widget.onUpdate(updated);
    setState(() => _record = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('อนุมัติการชำระเงินและออกใบเสร็จเรียบร้อยแล้ว'),
        backgroundColor: Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendReceiptLine() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ส่งใบเสร็จรับเงินเข้า LINE ห้อง ${_record.roomNumber} เรียบร้อยแล้ว'),
        backgroundColor: const Color(0xFF06C755),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _record;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grabber Handle
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(40),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ห้อง ${r.roomNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r.tenantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'รอบบิล: สิงหาคม 2026',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.xmark, size: 16, color: Color(0xFF8E8E93)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bill Breakdown Box (Apple Receipt style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withAlpha(8)),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('ค่าเช่าห้องพัก', r.roomRent),
                  const SizedBox(height: 8),
                  _buildReceiptRow('ค่าไฟฟ้า', r.electricCost),
                  const SizedBox(height: 8),
                  _buildReceiptRow('ค่าน้ำประปา', r.waterCost),
                  const SizedBox(height: 8),
                  _buildReceiptRow('ค่าบริการส่วนกลาง/เน็ต', r.commonFee),
                  if (r.otherFee > 0) ...[
                    const SizedBox(height: 8),
                    _buildReceiptRow('ค่าธรรมเนียมอื่นๆ', r.otherFee),
                  ],
                  const Divider(height: 20, thickness: 0.8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ยอดรวมทั้งสิ้น',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '฿${_formatCurrency(r.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Status info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withAlpha(10), width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        r.isPaid
                            ? CupertinoIcons.checkmark_circle_fill
                            : r.isPendingVerification
                                ? CupertinoIcons.clock_fill
                                : CupertinoIcons.exclamationmark_circle_fill,
                        size: 18,
                        color: r.isPaid
                            ? const Color(0xFF34C759)
                            : r.isPendingVerification
                                ? const Color(0xFFFF9500)
                                : const Color(0xFFFF3B30),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'สถานะ: ${r.status.description}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (r.paymentMethod != null)
                    Text(
                      r.paymentMethod!.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (r.isPendingVerification)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _approvePayment,
                  icon: const Icon(CupertinoIcons.checkmark_alt, size: 18, color: Colors.white),
                  label: const Text(
                    'ตรวจสอบสลิปและอนุมัติการชำระเงิน',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
            else if (r.isPaid)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _sendReceiptLine,
                  icon: const Icon(CupertinoIcons.paperplane_fill, size: 18, color: Colors.white),
                  label: const Text(
                    'ส่งใบเสร็จ e-Receipt ทาง LINE OA',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06C755),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ส่งข้อความแจ้งเตือนค่าเช่าห้อง ${r.roomNumber} ทาง LINE OA แล้ว'),
                        backgroundColor: const Color(0xFF06C755),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.bell_fill, size: 18, color: Colors.white),
                  label: const Text(
                    'ส่งข้อความทวงถามค่าเช่าทาง LINE',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          '฿${_formatCurrency(amount)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
