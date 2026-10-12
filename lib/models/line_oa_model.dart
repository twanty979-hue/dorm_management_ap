import 'package:flutter/material.dart';

enum LineMessageType {
  billNotification('แจ้งบิลค่าเช่า'),
  paymentReceipt('ใบเสร็จรับเงิน'),
  dueReminder('แจ้งเตือนชำระ'),
  maintenanceUpdate('แจ้งสถานะซ่อม'),
  announcement('ประกาศทั่วไป');

  final String label;
  const LineMessageType(this.label);
}

enum LineDeliveryStatus {
  sent('ส่งแล้ว'),
  delivered('ได้รับแล้ว'),
  read('อ่านแล้ว'),
  failed('ส่งไม่สำเร็จ');

  final String label;
  const LineDeliveryStatus(this.label);
}

/// Model for LINE OA message logs / chat history
class LineOaMessage {
  final String id;
  final String roomNumber;
  final String tenantName;
  final String messageTitle;
  final String messageBody;
  final LineMessageType type;
  final LineDeliveryStatus status;
  final DateTime sentAt;
  final String? avatarUrl;

  const LineOaMessage({
    required this.id,
    required this.roomNumber,
    required this.tenantName,
    required this.messageTitle,
    required this.messageBody,
    required this.type,
    required this.status,
    required this.sentAt,
    this.avatarUrl,
  });

  static List<LineOaMessage> get sampleMessages => [
        LineOaMessage(
          id: '1',
          roomNumber: '101',
          tenantName: 'สมชาย ใจดี',
          messageTitle: 'ใบแจ้งหนี้ค่าเช่าห้อง ประจำเดือน ส.ค. 2026',
          messageBody: 'ยอดรวมทั้งสิ้น 5,450 บาท (ค่าห้อง 4,500 + ค่าน้ำ 150 + ค่าไฟ 800)',
          type: LineMessageType.billNotification,
          status: LineDeliveryStatus.read,
          sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        LineOaMessage(
          id: '2',
          roomNumber: '203',
          tenantName: 'กนกวรรณ รุ่งเรือง',
          messageTitle: 'แจ้งเตือนกำหนดชำระค่าเช่าห้อง',
          messageBody: 'กรุณาชำระเงินภายในวันที่ 5 ส.ค. เพื่อหลีกเลี่ยงค่าปรับล่าช้า',
          type: LineMessageType.dueReminder,
          status: LineDeliveryStatus.read,
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        LineOaMessage(
          id: '3',
          roomNumber: '204',
          tenantName: 'ธนากร มั่งมี',
          messageTitle: 'อัปเดตสถานะงานแจ้งซ่อม',
          messageBody: 'ช่างวิเชียรได้เข้าตรวจสอบลูกบิดประตูห้องน้ำแล้ว และดำเนินการเปลี่ยนเสร็จสิ้น',
          type: LineMessageType.maintenanceUpdate,
          status: LineDeliveryStatus.delivered,
          sentAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        LineOaMessage(
          id: '4',
          roomNumber: '305',
          tenantName: 'อรุณี สุขเกษม',
          messageTitle: 'ใบเสร็จรับเงินค่าเช่าห้อง #REC-202608-305',
          messageBody: 'ได้รับเงินชำระจำนวน 5,800 บาท เรียบร้อยแล้ว ขอบคุณที่ใช้บริการค่ะ',
          type: LineMessageType.paymentReceipt,
          status: LineDeliveryStatus.read,
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        LineOaMessage(
          id: '5',
          roomNumber: 'ทุกห้อง',
          tenantName: 'ผู้เช่าทั้งหมด (Broadcast)',
          messageTitle: 'ประกาศ: ปิดปรับปรุงระบบน้ำประปาชั่วคราว',
          messageBody: 'วันเสาร์ที่ 30 ส.ค. เวลา 09:00 - 12:00 น. เพื่อทำการล้างแทงก์น้ำประจำปี',
          type: LineMessageType.announcement,
          status: LineDeliveryStatus.sent,
          sentAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
}

/// Model for LINE OA message template
class LineTemplateItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final LineMessageType type;
  final String defaultBody;

  const LineTemplateItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.type,
    required this.defaultBody,
  });

  static List<LineTemplateItem> get sampleTemplates => [
        const LineTemplateItem(
          id: 'tpl_1',
          title: 'บิลแจ้งหนี้ประจำเดือน',
          subtitle: 'Flex Message รูปแบบบิลพร้อม QR Code พร้อมเพย์',
          icon: Icons.receipt_long_rounded,
          iconColor: Color(0xFFC45A34),
          type: LineMessageType.billNotification,
          defaultBody: 'เรียนผู้เช่าห้อง {room_number}\nยอดชำระประจำเดือน {month} รวมทั้งสิ้น {total_amount} บาท กำหนดชำระภายในวันที่ {due_date}',
        ),
        const LineTemplateItem(
          id: 'tpl_2',
          title: 'แจ้งเตือนครบกำหนดชำระ',
          subtitle: 'แจ้งเตือนก่อนถึงวันครบกำหนด 3 วัน',
          icon: Icons.notifications_active_rounded,
          iconColor: Color(0xFFE2724D),
          type: LineMessageType.dueReminder,
          defaultBody: 'แจ้งเตือน: ค่าเช่าห้อง {room_number} ประจำเดือน {month} จะครบกำหนดชำระในอีก 3 วัน ({due_date})',
        ),
        const LineTemplateItem(
          id: 'tpl_3',
          title: 'ใบเสร็จรับเงิน (e-Receipt)',
          subtitle: 'ส่งหลักฐานยืนยันเมื่อตรวจสอบการโอนเงินแล้ว',
          icon: Icons.check_circle_rounded,
          iconColor: Color(0xFF34C759),
          type: LineMessageType.paymentReceipt,
          defaultBody: 'ยืนยันการรับชำระเงิน ห้อง {room_number} จำนวน {total_amount} บาท เรียบร้อยแล้ว ขอบคุณค่ะ',
        ),
        const LineTemplateItem(
          id: 'tpl_4',
          title: 'แจ้งสถานะงานซ่อม',
          subtitle: 'แจ้งเมื่อช่างรับงานหรือซ่อมเสร็จแล้ว',
          icon: Icons.build_rounded,
          iconColor: Color(0xFF007AFF),
          type: LineMessageType.maintenanceUpdate,
          defaultBody: 'งานแจ้งซ่อม {maintenance_title} ของห้อง {room_number} ได้ดำเนินการเสร็จสิ้นเรียบร้อยแล้ว',
        ),
        const LineTemplateItem(
          id: 'tpl_5',
          title: 'ประกาศข่าวสารหอพัก',
          subtitle: 'ส่งข้อความบรอดแคสต์ถึงผู้เช่าทุกคน',
          icon: Icons.campaign_rounded,
          iconColor: Color(0xFFAF52DE),
          type: LineMessageType.announcement,
          defaultBody: 'ประกาศจากนิติบุคคล: {announcement_text}',
        ),
      ];
}
