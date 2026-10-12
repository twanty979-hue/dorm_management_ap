import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Quick Action Buttons for LINE OA
class LineQuickActions extends StatelessWidget {
  final VoidCallback onBroadcastTap;
  final VoidCallback onSendBillTap;
  final VoidCallback onDueReminderTap;

  const LineQuickActions({
    super.key,
    required this.onBroadcastTap,
    required this.onSendBillTap,
    required this.onDueReminderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context,
          icon: CupertinoIcons.paperplane_fill,
          label: 'Broadcast',
          sublabel: 'ส่งทุกห้อง',
          color: const Color(0xFF06C755),
          bgColor: const Color(0xFFEBF9F0),
          onTap: onBroadcastTap,
        ),
        const SizedBox(width: 10),
        _buildActionButton(
          context,
          icon: CupertinoIcons.doc_text_fill,
          label: 'ส่งบิลห้อง',
          sublabel: 'Flex Message',
          color: AppColors.primary,
          bgColor: AppColors.primaryContainer,
          onTap: onSendBillTap,
        ),
        const SizedBox(width: 10),
        _buildActionButton(
          context,
          icon: CupertinoIcons.bell_fill,
          label: 'เตือนชำระ',
          sublabel: 'ยอดค้าง 5 ห้อง',
          color: const Color(0xFFFF9500),
          bgColor: const Color(0xFFFFF4E5),
          onTap: onDueReminderTap,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
