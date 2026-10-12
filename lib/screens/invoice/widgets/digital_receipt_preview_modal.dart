import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Luxury Apple-styled Digital Receipt & Invoice Preview Modal
class DigitalReceiptPreviewModal extends StatelessWidget {
  final String roomNumber;
  final String tenantName;
  final String billingMonth;
  final int rentAmount;
  final double prevElectric;
  final double currElectric;
  final double electricRate;
  final double prevWater;
  final double currWater;
  final double waterRate;
  final int commonFee;
  final VoidCallback? onConfirmSend;

  const DigitalReceiptPreviewModal({
    super.key,
    required this.roomNumber,
    required this.tenantName,
    required this.billingMonth,
    required this.rentAmount,
    required this.prevElectric,
    required this.currElectric,
    required this.electricRate,
    required this.prevWater,
    required this.currWater,
    required this.waterRate,
    this.commonFee = 300,
    this.onConfirmSend,
  });

  static void show(
    BuildContext context, {
    required String roomNumber,
    required String tenantName,
    required String billingMonth,
    required int rentAmount,
    required double prevElectric,
    required double currElectric,
    required double electricRate,
    required double prevWater,
    required double currWater,
    required double waterRate,
    int commonFee = 300,
    VoidCallback? onConfirmSend,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DigitalReceiptPreviewModal(
        roomNumber: roomNumber,
        tenantName: tenantName,
        billingMonth: billingMonth,
        rentAmount: rentAmount,
        prevElectric: prevElectric,
        currElectric: currElectric,
        electricRate: electricRate,
        prevWater: prevWater,
        currWater: currWater,
        waterRate: waterRate,
        commonFee: commonFee,
        onConfirmSend: onConfirmSend,
      ),
    );
  }

  double get _electricUnits =>
      (currElectric >= prevElectric) ? currElectric - prevElectric : 0;
  double get _electricTotal => _electricUnits * electricRate;

  double get _waterUnits =>
      (currWater >= prevWater) ? currWater - prevWater : 0;
  double get _waterTotal => _waterUnits * waterRate;

  double get _grandTotal =>
      rentAmount + _electricTotal + _waterTotal + commonFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ตัวอย่างใบแจ้งหนี้ดิจิทัล',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 14,
                      color: AppColors.iconDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Receipt Card Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withAlpha(10), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Receipt Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(90),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'The Green Residence',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ใบแจ้งหนี้ประจำเดือน $billingMonth',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ห้อง $roomNumber',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ผู้เช่า: $tenantName',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'กำหนดชำระ: 5 ของเดือน',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFD70015),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Jagged / Dashed Separator
                    Row(
                      children: List.generate(
                        24,
                        (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              height: 1.2,
                              color: Colors.black.withAlpha(25),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bill Itemized Breakdown
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildItemRow(
                            title: 'ค่าเช่าห้องพักรายเดือน',
                            subtitle: 'ห้องพักปรับอากาศ ชั้น ${(int.tryParse(roomNumber) ?? 100) ~/ 100}',
                            amount: '฿${rentAmount.toStringAsFixed(0)}',
                            isBold: true,
                          ),
                          const Divider(height: 20, color: Color(0x10000000)),
                          _buildItemRow(
                            title: 'ค่าไฟฟ้า (มิเตอร์)',
                            subtitle: '${prevElectric.toStringAsFixed(0)} → ${currElectric.toStringAsFixed(0)} (${_electricUnits.toStringAsFixed(0)} หน่วย x ฿${electricRate.toStringAsFixed(0)})',
                            amount: '฿${_electricTotal.toStringAsFixed(0)}',
                          ),
                          const Divider(height: 20, color: Color(0x10000000)),
                          _buildItemRow(
                            title: 'ค่าน้ำประปา (มิเตอร์)',
                            subtitle: '${prevWater.toStringAsFixed(0)} → ${currWater.toStringAsFixed(0)} (${_waterUnits.toStringAsFixed(0)} หน่วย x ฿${waterRate.toStringAsFixed(0)})',
                            amount: '฿${_waterTotal.toStringAsFixed(0)}',
                          ),
                          const Divider(height: 20, color: Color(0x10000000)),
                          _buildItemRow(
                            title: 'ค่าส่วนกลาง & อินเทอร์เน็ต Wi-Fi',
                            subtitle: 'บริการทำความสะอาดส่วนกลาง & ค่าขยะ',
                            amount: '฿$commonFee',
                          ),
                          const SizedBox(height: 18),

                          // Total Bar
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withAlpha(8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ยอดรวมที่ต้องชำระ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '฿${_grandTotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // PromptPay QR Preview
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF003D6D), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(8),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.qr_code_2_rounded, size: 20, color: Color(0xFF003D6D)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Thai QR PromptPay',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF003D6D),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 110,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'สแกนจ่ายผ่านแอปธนาคารทุกธนาคาร',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: AppColors.textSecondary,
                                        ),
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
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black.withAlpha(10), width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('แชร์ใบแจ้งหนี้เป็นภาพ / PDF สำเร็จ'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.share, size: 16),
                    label: const Text('แชร์บิล'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: Colors.black.withAlpha(20)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirmSend != null) {
                        onConfirmSend!();
                      }
                    },
                    icon: const Icon(CupertinoIcons.paperplane_fill, size: 16, color: Colors.white),
                    label: const Text(
                      'ยืนยัน & ส่ง LINE OA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06C755),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String title,
    required String subtitle,
    required String amount,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
