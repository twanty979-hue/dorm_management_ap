enum RoomStatus {
  occupied('มีผู้เช่า', 0xFFE8F5E9, 0xFF2E7D32),
  vacant('ห้องว่าง', 0xFFFBECE5, 0xFFC45A34),
  maintenance('แจ้งซ่อม', 0xFFFFF3E0, 0xFFE65100);

  final String label;
  final int bgColorValue;
  final int textColorValue;

  const RoomStatus(this.label, this.bgColorValue, this.textColorValue);
}

/// Model representing a dormitory room
class RoomItem {
  final String roomNumber;
  final int floor;
  final String roomType;
  final int monthlyPrice;
  final RoomStatus status;
  final String? tenantName;
  final String? tenantPhone;
  final String? checkInDate;
  final double? waterRate;
  final double? electricRate;

  const RoomItem({
    required this.roomNumber,
    required this.floor,
    required this.roomType,
    required this.monthlyPrice,
    required this.status,
    this.tenantName,
    this.tenantPhone,
    this.checkInDate,
    this.waterRate,
    this.electricRate,
  });

  bool get isOccupied => status == RoomStatus.occupied;
  bool get isVacant => status == RoomStatus.vacant;
  bool get isMaintenance => status == RoomStatus.maintenance;

  static List<RoomItem> get sampleRooms => [
        const RoomItem(
          roomNumber: '101',
          floor: 1,
          roomType: 'ห้องแอร์ • เตียงเดี่ยว',
          monthlyPrice: 4500,
          status: RoomStatus.maintenance,
          tenantName: 'คุณสมศักดิ์ สุขใจ',
          tenantPhone: '081-234-5678',
          checkInDate: '01/01/2026',
        ),
        const RoomItem(
          roomNumber: '102',
          floor: 1,
          roomType: 'ห้องแอร์ • เตียงเดี่ยว',
          monthlyPrice: 4500,
          status: RoomStatus.occupied,
          tenantName: 'คุณกานดา วงศ์วาน',
          tenantPhone: '089-876-5432',
          checkInDate: '15/02/2026',
        ),
        const RoomItem(
          roomNumber: '103',
          floor: 1,
          roomType: 'ห้องพัดลม • เตียงเดี่ยว',
          monthlyPrice: 3500,
          status: RoomStatus.vacant,
        ),
        const RoomItem(
          roomNumber: '104',
          floor: 1,
          roomType: 'ห้องแอร์ • เตียงคู่',
          monthlyPrice: 5000,
          status: RoomStatus.occupied,
          tenantName: 'คุณวิชัย เจริญผล',
          tenantPhone: '086-555-1234',
          checkInDate: '01/03/2026',
        ),
        const RoomItem(
          roomNumber: '201',
          floor: 2,
          roomType: 'ห้องแอร์ • เตียงเดี่ยว',
          monthlyPrice: 4500,
          status: RoomStatus.occupied,
          tenantName: 'คุณนภา รัตนไพบูลย์',
          tenantPhone: '090-111-2233',
          checkInDate: '10/01/2026',
        ),
        const RoomItem(
          roomNumber: '202',
          floor: 2,
          roomType: 'ห้องแอร์ • เตียงเดี่ยว',
          monthlyPrice: 4500,
          status: RoomStatus.vacant,
        ),
        const RoomItem(
          roomNumber: '203',
          floor: 2,
          roomType: 'ห้องแอร์ • เตียงคู่',
          monthlyPrice: 5200,
          status: RoomStatus.maintenance,
          tenantName: 'คุณธนากร มิ่งเมือง',
          tenantPhone: '084-999-8877',
          checkInDate: '05/02/2026',
        ),
        const RoomItem(
          roomNumber: '204',
          floor: 2,
          roomType: 'ห้องแอร์ • เตียงเดี่ยว',
          monthlyPrice: 4500,
          status: RoomStatus.occupied,
          tenantName: 'คุณชลธิชา มีสุข',
          tenantPhone: '095-444-3322',
          checkInDate: '20/01/2026',
        ),
        const RoomItem(
          roomNumber: '301',
          floor: 3,
          roomType: 'ห้องแอร์ VIP • ระเบียงกว้าง',
          monthlyPrice: 6000,
          status: RoomStatus.occupied,
          tenantName: 'คุณพัชรา เพียรดี',
          tenantPhone: '082-777-6655',
          checkInDate: '01/12/2025',
        ),
        const RoomItem(
          roomNumber: '302',
          floor: 3,
          roomType: 'ห้องแอร์ VIP • ระเบียงกว้าง',
          monthlyPrice: 6000,
          status: RoomStatus.vacant,
        ),
      ];
}
