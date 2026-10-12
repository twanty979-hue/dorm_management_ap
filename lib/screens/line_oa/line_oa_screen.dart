import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/line_oa_model.dart';
import 'widgets/line_broadcast_modal.dart';
import 'widgets/line_chat_history_list.dart';
import 'widgets/line_quick_actions.dart';
import 'widgets/line_settings_card.dart';
import 'widgets/line_status_card.dart';
import 'widgets/line_template_list.dart';
import 'widgets/line_template_preview_modal.dart';

/// Full Apple iOS-styled LINE OA Management Screen
class LineOaScreen extends StatefulWidget {
  const LineOaScreen({super.key});

  @override
  State<LineOaScreen> createState() => _LineOaScreenState();
}

class _LineOaScreenState extends State<LineOaScreen> {
  int _selectedTabIndex = 0; // 0: Templates, 1: History, 2: Settings
  final List<LineOaMessage> _messages = List.from(LineOaMessage.sampleMessages);
  final List<LineTemplateItem> _templates = LineTemplateItem.sampleTemplates;

  void _onBroadcastSend(String title, String body, String target) {
    setState(() {
      _messages.insert(
        0,
        LineOaMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomNumber: target,
          tenantName: target,
          messageTitle: title,
          messageBody: body,
          type: LineMessageType.announcement,
          status: LineDeliveryStatus.sent,
          sentAt: DateTime.now(),
        ),
      );
    });
  }

  void _onOpenBroadcastModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LineBroadcastModal(onSend: _onBroadcastSend),
    );
  }

  void _onSendBillModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('ส่งบิลค่าเช่าผ่าน LINE OA'),
        message: const Text('เลือกกลุ่มห้องที่ต้องการส่งบิลประจำเดือน'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _onBroadcastSend(
                'บิลค่าเช่าประจำเดือน ส.ค. 2026',
                'ส่งบิลแจ้งหนี้พร้อม QR Code ให้กับทุกห้องที่มีการจดมิเตอร์แล้ว',
                'ทุกห้อง (42 ห้อง)',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งบิลค่าเช่าให้ 42 ห้องเรียบร้อยแล้ว'),
                  backgroundColor: Color(0xFF06C755),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('ส่งทุกห้องที่ออกบิลแล้ว (42 ห้อง)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('เปิดหน้ารายการห้องเพื่อเลือกส่งเฉพาะห้อง'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('เลือกห้องที่ต้องการส่ง...'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
      ),
    );
  }

  void _onDueReminderModal() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('ส่งแจ้งเตือนยอดค้างชำระ'),
        content: const Text(
          'ระบบจะส่งข้อความแจ้งเตือนไปยัง 5 ห้องที่เลยกำหนดชำระเงิน ต้องการดำเนินการหรือไม่?',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _onBroadcastSend(
                'แจ้งเตือนค้างชำระค่าเช่าห้อง',
                'กรุณาชำระเงินค่าเช่าห้องที่เลยกำหนดชำระ เพื่อหลีกเลี่ยงค่าปรับ',
                'ห้องที่ค้างชำระ (5 ห้อง)',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งข้อความแจ้งเตือน 5 ห้องเรียบร้อยแล้ว'),
                  backgroundColor: Color(0xFF06C755),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('ส่งแจ้งเตือน (5 ห้อง)'),
          ),
        ],
      ),
    );
  }

  void _onSelectTemplate(LineTemplateItem tpl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LineTemplatePreviewModal(
        template: tpl,
        onSend: (target) {
          _onBroadcastSend(tpl.title, tpl.defaultBody, target);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withAlpha(8)),
              ),
              child: const Icon(
                CupertinoIcons.chevron_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Text(
          'ข้อความ Line OA',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: _onOpenBroadcastModal,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.paperplane_fill,
                  color: Color(0xFF06C755),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Colors.black.withAlpha(12),
            height: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Quota Card
            const LineStatusCard(),
            const SizedBox(height: 14),

            // Quick Actions
            LineQuickActions(
              onBroadcastTap: _onOpenBroadcastModal,
              onSendBillTap: _onSendBillModal,
              onDueReminderTap: _onDueReminderModal,
            ),
            const SizedBox(height: 18),

            // Segmented Tab Selector (Apple iOS style)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildSegmentTab(0, 'เทมเพลตข้อความ'),
                  _buildSegmentTab(1, 'ประวัติการส่ง (${_messages.length})'),
                  _buildSegmentTab(2, 'ตั้งค่า API'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            if (_selectedTabIndex == 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'เทมเพลตมาตรฐาน (Flex Message)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '5 เทมเพลต',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LineTemplateList(
                templates: _templates,
                onSelectTemplate: _onSelectTemplate,
              ),
            ] else if (_selectedTabIndex == 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ประวัติข้อความล่าสุด',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'อัปเดตล่าสุด เมื่อครู่',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LineChatHistoryList(messages: _messages),
            ] else ...[
              const LineSettingsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
