import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/tenant_item.dart';

/// Apple iOS Bottom Sheet modal showing full tenant dossier with AI Analysis & Lease Termination
class TenantDetailModal extends StatefulWidget {
  final TenantItem tenant;
  final VoidCallback? onTenantUpdated;

  const TenantDetailModal({
    super.key,
    required this.tenant,
    this.onTenantUpdated,
  });

  static void show(BuildContext context, TenantItem tenant, {VoidCallback? onTenantUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TenantDetailModal(
        tenant: tenant,
        onTenantUpdated: onTenantUpdated,
      ),
    );
  }

  @override
  State<TenantDetailModal> createState() => _TenantDetailModalState();
}

class _TenantDetailModalState extends State<TenantDetailModal> {
  bool _isProcessingCheckout = false;
  String? _generatedAiMessage;

  void _generateAiNotice(String type) {
    setState(() {
      if (type == 'renewal') {
        _generatedAiMessage =
            'สวัสดีครับ/ค่ะ ${widget.tenant.name} 🏢 แจ้งเตือนจากหอพัก The Green Residence สัญญาเช่าห้อง ${widget.tenant.roomNumber} ของท่านจะสิ้นสุดในวันที่ ${widget.tenant.endDate} หากประสงค์จะต่อสัญญาเช่าต่อ สามารถแจ้งแอดมินได้เลยนะครับ ขอบคุณครับ';
      } else if (type == 'rules') {
        _generatedAiMessage =
            'สวัสดีครับ/ค่ะ ${widget.tenant.name} 📢 ขอความร่วมมืองดส่งเสียงดังหลังเวลา 22:00 น. และช่วยกันรักษาความสะอาดบริเวณทางเดินส่วนกลางเพื่อสุขอนามัยที่ดีของชาวหอพักครับ';
      } else {
        _generatedAiMessage =
            'สวัสดีครับ/ค่ะ ${widget.tenant.name} 🧾 ยอดค่าเช่าและค่าน้ำ-ไฟ ประจำเดือนของห้อง ${widget.tenant.roomNumber} ออกแล้ว สามารถตรวจสอบบิลและชำระได้ผ่านระบบ ขอบคุณครับ';
      }
    });
  }

  void _handleCheckout() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('ยืนยันการย้ายออก'),
        content: Text(
          'ต้องการบันทึกการย้ายออกของ ${widget.tenant.name} (ห้อง ${widget.tenant.roomNumber}) และคืนห้องพักเป็นสถานะ "ว่าง" หรือไม่?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยันย้ายออก'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessingCheckout = true);
      final result = await ApiService.terminateLease(widget.tenant.id);
      if (!mounted) return;
      setState(() => _isProcessingCheckout = false);

      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onTenantUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกการย้ายออกและคืนห้อง ${widget.tenant.roomNumber} เรียบร้อยแล้ว'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'เกิดข้อผิดพลาดในการย้ายออก'),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // iOS drag indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      widget.tenant.name.isNotEmpty
                          ? widget.tenant.name.substring(widget.tenant.name.startsWith('คุณ') ? 3 : 0, widget.tenant.name.startsWith('คุณ') ? 4 : 1)
                          : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tenant.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'ห้องพัก ${widget.tenant.roomNumber} (ชั้น ${widget.tenant.floor})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quick Contact Action Pills (Call & LINE)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('กำลังโทรออกไปยัง ${widget.tenant.phone}...'),
                            backgroundColor: const Color(0xFF34C759),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F9EE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF34C759).withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(CupertinoIcons.phone_fill, size: 16, color: Color(0xFF248A3D)),
                            SizedBox(width: 6),
                            Text(
                              'โทรหาผู้เช่า',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF248A3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เปิดแชท LINE ติดต่อ ${widget.tenant.name}...'),
                            backgroundColor: const Color(0xFF06C755),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF9F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF06C755).withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(CupertinoIcons.chat_bubble_fill, size: 16, color: Color(0xFF06C755)),
                            SizedBox(width: 6),
                            Text(
                              'ส่ง LINE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF06C755),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Lease Duration Progress Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withAlpha(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ความคืบหน้าสัญญาเช่า',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.tenant.isExpiringSoon ? const Color(0xFFFFECEB) : const Color(0xFFEBF3FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.tenant.isExpiringSoon ? 'ใกล้หมดสัญญา' : 'ปกติ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.tenant.isExpiringSoon ? const Color(0xFFFF3B30) : const Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: widget.tenant.isExpiringSoon ? 0.90 : 0.65,
                        backgroundColor: const Color(0xFFE5E5EA),
                        color: widget.tenant.isExpiringSoon ? const Color(0xFFFF3B30) : AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('เริ่ม ${widget.tenant.startDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('สิ้นสุด ${widget.tenant.endDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),



              // Contact & Contract Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withAlpha(8)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: CupertinoIcons.phone_fill,
                      iconColor: const Color(0xFF34C759),
                      label: 'เบอร์โทรศัพท์',
                      value: widget.tenant.phone,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: CupertinoIcons.chat_bubble_fill,
                      iconColor: const Color(0xFF06C755),
                      label: 'LINE ID',
                      value: widget.tenant.lineId,
                    ),
                    if (widget.tenant.idCardNumber.isNotEmpty) ...[
                      const Divider(height: 20),
                      _buildDetailRow(
                        icon: CupertinoIcons.person_badge_plus_fill,
                        iconColor: const Color(0xFF007AFF),
                        label: 'เลขบัตรประชาชน',
                        value: widget.tenant.idCardNumber,
                      ),
                    ],
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: CupertinoIcons.doc_text_fill,
                      iconColor: AppColors.primary,
                      label: 'ระยะเวลาสัญญา',
                      value: '${widget.tenant.startDate} - ${widget.tenant.endDate}',
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      iconColor: const Color(0xFFD47C38),
                      label: 'ค่าเช่าห้อง',
                      value: '฿${widget.tenant.monthlyRent} / เดือน',
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      iconColor: const Color(0xFF5856D6),
                      label: 'เงินประกันสัญญา',
                      value: '฿${widget.tenant.depositAmount.toInt()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 🤖 AI 1-Tap LINE Notification Generator
              const Text(
                '🤖 AI สร้างข้อความแจ้งเตือนด่วน (LINE OA)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _generateAiNotice('renewal'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF7B61FF), width: 1),
                      ),
                      child: const Text('เตือนต่อสัญญา', style: TextStyle(fontSize: 11.5, color: Color(0xFF7B61FF), fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _generateAiNotice('bill'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF007AFF), width: 1),
                      ),
                      child: const Text('แจ้งยอดบิล', style: TextStyle(fontSize: 11.5, color: Color(0xFF007AFF), fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _generateAiNotice('rules'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFFF9500), width: 1),
                      ),
                      child: const Text('แจ้งเตือนหอพัก', style: TextStyle(fontSize: 11.5, color: Color(0xFFFF9500), fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),

              if (_generatedAiMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withAlpha(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _generatedAiMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _generatedAiMessage!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('คัดลอกข้อความ AI เรียบร้อยแล้ว'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(CupertinoIcons.doc_on_doc, size: 14),
                            label: const Text('คัดลอกข้อความ', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Bottom Actions: Terminate Lease + Close
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessingCheckout ? null : _handleCheckout,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        foregroundColor: const Color(0xFFFF3B30),
                        side: const BorderSide(color: Color(0xFFFF3B30), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessingCheckout
                          ? const CupertinoActivityIndicator(color: Color(0xFFFF3B30))
                          : const Text(
                              'ย้ายออก / คืนห้อง',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'เสร็จสิ้น',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
