import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Modal for adjusting electric rate, water rate, and common fee
class EditRateModal extends StatefulWidget {
  final double electricRate;
  final double waterRate;
  final int commonFee;
  final Function(double elec, double water, int common) onSave;

  const EditRateModal({
    super.key,
    required this.electricRate,
    required this.waterRate,
    required this.commonFee,
    required this.onSave,
  });

  @override
  State<EditRateModal> createState() => _EditRateModalState();
}

class _EditRateModalState extends State<EditRateModal> {
  late TextEditingController _elecController;
  late TextEditingController _waterController;
  late TextEditingController _commonController;

  @override
  void initState() {
    super.initState();
    _elecController = TextEditingController(text: widget.electricRate.toStringAsFixed(1));
    _waterController = TextEditingController(text: widget.waterRate.toStringAsFixed(1));
    _commonController = TextEditingController(text: widget.commonFee.toString());
  }

  @override
  void dispose() {
    _elecController.dispose();
    _waterController.dispose();
    _commonController.dispose();
    super.dispose();
  }

  void _submit() {
    final elec = double.tryParse(_elecController.text.trim()) ?? widget.electricRate;
    final water = double.tryParse(_waterController.text.trim()) ?? widget.waterRate;
    final common = int.tryParse(_commonController.text.trim()) ?? widget.commonFee;

    widget.onSave(elec, water, common);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกอัตราค่าน้ำ ค่าไฟ และค่าบริการใหม่เรียบร้อยแล้ว'),
        backgroundColor: Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Grabber
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
                const Text(
                  'ตั้งค่าอัตราค่าน้ำ - ค่าไฟ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
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

            // Electric Rate
            const Text(
              'อัตราค่าไฟฟ้า (บาท / หน่วย)',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _elecController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '8.0',
                prefixIcon: const Icon(CupertinoIcons.bolt_fill, size: 18, color: Color(0xFFD47C38)),
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Water Rate
            const Text(
              'อัตราค่าน้ำประปา (บาท / หน่วย)',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _waterController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '18.0',
                prefixIcon: const Icon(CupertinoIcons.drop_fill, size: 18, color: Color(0xFF007AFF)),
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Common Fee
            const Text(
              'ค่าบริการส่วนกลาง / เน็ต (บาท / เดือน)',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _commonController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '300',
                prefixIcon: const Icon(CupertinoIcons.wifi, size: 18, color: Color(0xFF5856D6)),
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'บันทึกอัตราค่าบริการ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
