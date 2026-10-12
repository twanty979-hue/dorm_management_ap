import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/line_oa_model.dart';

/// List of recent LINE OA messages sent to tenants
class LineChatHistoryList extends StatelessWidget {
  final List<LineOaMessage> messages;

  const LineChatHistoryList({
    super.key,
    required this.messages,
  });

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} นาทีที่แล้ว';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ชม. ที่แล้ว';
    } else {
      return '${diff.inDays} วันที่แล้ว';
    }
  }

  Widget _buildStatusBadge(LineDeliveryStatus status) {
    switch (status) {
      case LineDeliveryStatus.read:
        return const Text(
          'อ่านแล้ว',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF06C755),
          ),
        );
      case LineDeliveryStatus.delivered:
        return const Text(
          'ส่งถึงแล้ว',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF007AFF),
          ),
        );
      case LineDeliveryStatus.sent:
        return const Text(
          'ส่งแล้ว',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        );
      case LineDeliveryStatus.failed:
        return const Text(
          'ส่งไม่สำเร็จ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF3B30),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _buildMessageCard(msg);
      },
    );
  }

  Widget _buildMessageCard(LineOaMessage msg) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Room + Tenant name and Time + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      'ห้อง ${msg.roomNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    msg.tenantName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildStatusBadge(msg.status),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(msg.sentAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Message Title
          Text(
            msg.messageTitle,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Message Body snippet
          Text(
            msg.messageBody,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
