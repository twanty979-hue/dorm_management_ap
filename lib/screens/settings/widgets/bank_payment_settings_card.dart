import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Apple iOS Inset Grouped card for Dormitory Bank & PromptPay Account Settings
class BankPaymentSettingsCard extends StatefulWidget {
  const BankPaymentSettingsCard({super.key});

  @override
  State<BankPaymentSettingsCard> createState() => _BankPaymentSettingsCardState();
}

class _BankPaymentSettingsCardState extends State<BankPaymentSettingsCard> {
  String _promptPayId = '089-123-4567';
  String _bankName = 'ธนาคารกสิกรไทย (KBANK)';
  String _accountNumber = '045-2-12345-6';
  String _accountHolder = 'คุณณภัทร วุฒิเดช (The Green Residence)';

  void _editBankDetails() {
    final promptPayCtrl = TextEditingController(text: _promptPayId);
    final bankCtrl = TextEditingController(text: _bankName);
    final accNumCtrl = TextEditingController(text: _accountNumber);
    final holderCtrl = TextEditingController(text: _accountHolder);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(modalContext).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            const Text(
              'แก้ไขบัญชีรับเงินและพร้อมเพย์',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            _buildTextField('เบอร์พร้อมเพย์ (PromptPay ID)', promptPayCtrl),
            const SizedBox(height: 12),
            _buildTextField('ธนาคาร', bankCtrl),
            const SizedBox(height: 12),
            _buildTextField('เลขที่บัญชี', accNumCtrl),
            const SizedBox(height: 12),
            _buildTextField('ชื่อบัญชีผู้รับเงิน', holderCtrl),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _promptPayId = promptPayCtrl.text.trim();
                  _bankName = bankCtrl.text.trim();
                  _accountNumber = accNumCtrl.text.trim();
                  _accountHolder = holderCtrl.text.trim();
                });
                Navigator.pop(modalContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกข้อมูลบัญชีรับเงินสำเร็จ'),
                    backgroundColor: Color(0xFF34C759),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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
                'บันทึกข้อมูล',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003D6D).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF003D6D)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'บัญชีรับเงินและ QR พร้อมเพย์',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _editBankDetails,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(120),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.pencil, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'แก้ไข',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bank Info Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withAlpha(6)),
            ),
            child: Column(
              children: [
                _buildInfoRow('พร้อมเพย์', _promptPayId, isBold: true),
                const Divider(height: 16, color: Color(0x10000000)),
                _buildInfoRow('ธนาคาร', _bankName),
                const Divider(height: 16, color: Color(0x10000000)),
                _buildInfoRow('เลขบัญชี', _accountNumber, isBold: true),
                const Divider(height: 16, color: Color(0x10000000)),
                _buildInfoRow('ชื่อบัญชี', _accountHolder),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
