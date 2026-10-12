import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card for contract rules, deposit policy, and house regulations
class ContractRulesCard extends StatelessWidget {
  const ContractRulesCard({super.key});

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
            children: const [
              Icon(CupertinoIcons.doc_text_fill, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'สัญญาเช่าและข้อตกลงหอพัก',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildItem('ระยะเวลาสัญญาขั้นต่ำ', '6 เดือน (ต่อสัญญาครั้งละ 1 ปี)'),
          const Divider(height: 14, thickness: 0.5),
          _buildItem('เงินประกันความเสียหาย', '2 เดือน + ค่าเช่าล่วงหน้า 1 เดือน'),
          const Divider(height: 14, thickness: 0.5),
          _buildItem('การแจ้งย้ายออก', 'แจ้งล่วงหน้าอย่างน้อย 30 วัน'),
          const Divider(height: 14, thickness: 0.5),
          _buildItem('กฎการเลี้ยงสัตว์', 'ห้ามเลี้ยงสัตว์ทุกชนิด', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isHighlight ? const Color(0xFFFF3B30) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
