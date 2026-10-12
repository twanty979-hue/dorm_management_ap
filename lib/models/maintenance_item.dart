enum MaintenanceStatus {
  pending('รอดำเนินการ', 'ใหม่'),
  inProgress('กำลังดำเนินการ', 'กำลังทำ'),
  completed('ดำเนินการแล้ว', 'เสร็จสิ้น'),
  cancelled('ยกเลิก', 'ยกเลิก');

  final String description;
  final String badgeText;

  const MaintenanceStatus(this.description, this.badgeText);
}

enum MaintenancePriority {
  urgent('ด่วนมาก'),
  normal('ปกติ'),
  low('ไม่เร่งด่วน');

  final String label;
  const MaintenancePriority(this.label);
}

/// Model representing a maintenance ticket
class MaintenanceItem {
  final String id;
  final String roomNumber;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final MaintenancePriority priority;
  final DateTime reportedAt;
  final String reporterName;
  final String reporterPhone;
  final String? technicianName;
  final double? estimatedCost;
  final String? notes;

  const MaintenanceItem({
    required this.id,
    required this.roomNumber,
    required this.title,
    this.description = '',
    required this.status,
    this.priority = MaintenancePriority.normal,
    required this.reportedAt,
    this.reporterName = 'ผู้เช่า',
    this.reporterPhone = '081-234-5678',
    this.technicianName,
    this.estimatedCost,
    this.notes,
  });

  String get displayTitle => 'ห้อง $roomNumber: $title';
  String get displayStatus => 'สถานะ: ${status.description}';
  bool get isPending => status == MaintenanceStatus.pending;
  bool get isInProgress => status == MaintenanceStatus.inProgress;
  bool get isCompleted => status == MaintenanceStatus.completed;

  MaintenanceItem copyWith({
    String? id,
    String? roomNumber,
    String? title,
    String? description,
    MaintenanceStatus? status,
    MaintenancePriority? priority,
    DateTime? reportedAt,
    String? reporterName,
    String? reporterPhone,
    String? technicianName,
    double? estimatedCost,
    String? notes,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reportedAt: reportedAt ?? this.reportedAt,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      technicianName: technicianName ?? this.technicianName,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
    );
  }

  static List<MaintenanceItem> get sampleList => [
        MaintenanceItem(
          id: '1',
          roomNumber: '101',
          title: 'หลอดไฟระเบียงดับ',
          description: 'หลอดไฟตรงระเบียงหลังห้องเปิดไม่ติด ลองเปลี่ยนหลอดแล้วยังไม่ติด น่าจะเป็นที่สวิตช์',
          status: MaintenanceStatus.pending,
          priority: MaintenancePriority.urgent,
          reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
          reporterName: 'สมชาย ใจดี',
          reporterPhone: '081-456-7890',
          technicianName: 'ช่างสมหมาย',
          estimatedCost: 250,
        ),
        MaintenanceItem(
          id: '2',
          roomNumber: '203',
          title: 'ก๊อกน้ำอ่างล้างหน้ารั่ว',
          description: 'มีน้ำหยดตลอดเวลาบริเวณใต้อ่างล้างหน้าในห้องน้ำ',
          status: MaintenanceStatus.pending,
          priority: MaintenancePriority.normal,
          reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
          reporterName: 'กนกวรรณ รุ่งเรือง',
          reporterPhone: '089-765-4321',
          technicianName: null,
          estimatedCost: 350,
        ),
        MaintenanceItem(
          id: '3',
          roomNumber: '204',
          title: 'ลูกบิดประตูห้องน้ำฝืด',
          description: 'ลูกบิดหมุนเปิดยาก บางครั้งล็อคแล้วเปิดไม่ออก',
          status: MaintenanceStatus.inProgress,
          priority: MaintenancePriority.normal,
          reportedAt: DateTime.now().subtract(const Duration(days: 1)),
          reporterName: 'ธนากร มั่งมี',
          reporterPhone: '082-345-6789',
          technicianName: 'ช่างวิเชียร',
          estimatedCost: 450,
          notes: 'สั่งซื้ออะไหล่ลูกบิดแล้ว กำลังเข้าเปลี่ยนช่วงบ่าย',
        ),
        MaintenanceItem(
          id: '4',
          roomNumber: '305',
          title: 'แอร์ไม่เย็น มีน้ำหยด',
          description: 'เปิดแอร์ 20 องศาแล้วยังมีแต่ลม และมีน้ำหยดลงบนที่นอน',
          status: MaintenanceStatus.completed,
          priority: MaintenancePriority.urgent,
          reportedAt: DateTime.now().subtract(const Duration(days: 2)),
          reporterName: 'อรุณี สุขเกษม',
          reporterPhone: '086-112-2334',
          technicianName: 'ช่างแอร์ไดกิ้น',
          estimatedCost: 600,
          notes: 'ล้างฟิลเตอร์และเติมน้ำยาแอร์เรียบร้อยแล้ว',
        ),
        MaintenanceItem(
          id: '5',
          roomNumber: '308',
          title: 'น้ำอุ่นไม่อุ่น',
          description: 'เครื่องทำน้ำอุ่นไฟเข้าแต่ไม่มีความร้อนเลย',
          status: MaintenanceStatus.completed,
          priority: MaintenancePriority.low,
          reportedAt: DateTime.now().subtract(const Duration(days: 3)),
          reporterName: 'ภานุวัชร์ แก้วดี',
          reporterPhone: '090-998-8776',
          technicianName: 'ช่างสมหมาย',
          estimatedCost: 300,
          notes: 'รีเซ็ตระบบเบรกเกอร์และเช็คขดลวดความร้อน ใช้งานได้ตามปกติ',
        ),
      ];
}
