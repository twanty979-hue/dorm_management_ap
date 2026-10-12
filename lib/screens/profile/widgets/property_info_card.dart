import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/dorm_property_item.dart';
import '../../../widgets/property_switcher_modal.dart';

/// Card showing dormitory property details and multi-branch management
class PropertyInfoCard extends StatefulWidget {
  const PropertyInfoCard({super.key});

  @override
  State<PropertyInfoCard> createState() => _PropertyInfoCardState();
}

class _PropertyInfoCardState extends State<PropertyInfoCard> {
  DormPropertyItem _currentProp = DormPropertyItem.sampleProperties[0];

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
                children: const [
                  Icon(CupertinoIcons.building_2_fill, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'ข้อมูลหอพักและสาขาที่ดูแล',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  PropertySwitcherModal.show(
                    context,
                    currentProperty: _currentProp,
                    onPropertySelected: (newProp) {
                      setState(() => _currentProp = newProp);
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'สลับสาขา',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(CupertinoIcons.chevron_down, size: 11, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow('สาขาปัจจุบัน', _currentProp.name),
          const Divider(height: 14, thickness: 0.5),
          _buildInfoRow('ที่ตั้ง', _currentProp.address),
          const Divider(height: 14, thickness: 0.5),
          _buildInfoRow('จำนวนห้อง', '${_currentProp.totalRooms} ห้อง (ว่าง ${_currentProp.vacantRooms} ห้อง)'),
          const Divider(height: 14, thickness: 0.5),
          _buildInfoRow('อัตราค่าน้ำ-ไฟ', '${_currentProp.electricRate} • ${_currentProp.waterRate}'),
          const Divider(height: 14, thickness: 0.5),
          _buildInfoRow('บัญชีรับเงิน', 'กสิกรไทย 098-2-34567-8 (พร้อมเพย์)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
