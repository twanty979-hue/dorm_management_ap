import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Card for notification preferences & automation toggles
class NotificationSettingsCard extends StatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  State<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  bool _autoSendLineBill = true;
  bool _autoRemindOverdue = true;
  bool _pushNewMaintenance = true;
  bool _pushSlipUploaded = true;

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
              Icon(CupertinoIcons.bell_fill, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'การแจ้งเตือนและระบบอัตโนมัติ',
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
          _buildToggle(
            title: 'ส่งบิลเข้า LINE OA อัตโนมัติ',
            subtitle: 'เมื่อบันทึกการจดเลขมิเตอร์ครบถ้วน',
            value: _autoSendLineBill,
            onChanged: (val) => setState(() => _autoSendLineBill = val),
          ),
          const Divider(height: 16, thickness: 0.5),
          _buildToggle(
            title: 'แจ้งเตือนผู้เช่าค้างชำระอัตโนมัติ',
            subtitle: 'เตือนล่วงหน้า 3 วัน และวันครบกำหนด',
            value: _autoRemindOverdue,
            onChanged: (val) => setState(() => _autoRemindOverdue = val),
          ),
          const Divider(height: 16, thickness: 0.5),
          _buildToggle(
            title: 'แจ้งเตือนเมื่อมีงานแจ้งซ่อมใหม่',
            subtitle: 'Push Notification ถึงผู้ดูแลทันที',
            value: _pushNewMaintenance,
            onChanged: (val) => setState(() => _pushNewMaintenance = val),
          ),
          const Divider(height: 16, thickness: 0.5),
          _buildToggle(
            title: 'แจ้งเตือนเมื่อผู้เช่าส่งสลิปโอนเงิน',
            subtitle: 'ส่งข้อความเพื่อรอการตรวจสอบสลิป',
            value: _pushSlipUploaded,
            onChanged: (val) => setState(() => _pushSlipUploaded = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
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
        CupertinoSwitch(
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
