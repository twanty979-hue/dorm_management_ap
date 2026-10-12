enum PaymentStatus {
  paid('ชำระแล้ว', 'ชำระแล้ว'),
  pendingVerification('รอตรวจสลิป', 'รอตรวจ'),
  unpaid('ค้างชำระ', 'ค้างชำระ');

  final String description;
  final String badgeText;
  const PaymentStatus(this.description, this.badgeText);
}

enum PaymentMethod {
  promptpay('พร้อมเพย์ QR'),
  bankTransfer('โอนเงินผ่านธนาคาร'),
  cash('เงินสด');

  final String label;
  const PaymentMethod(this.label);
}

/// Transaction record per room for the selected billing cycle
class RoomBillRecord {
  final String id;
  final String roomNumber;
  final String tenantName;
  final double roomRent;
  final double electricCost;
  final double waterCost;
  final double commonFee;
  final double otherFee;
  final PaymentStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime? paidAt;
  final String? slipUrl;

  const RoomBillRecord({
    required this.id,
    required this.roomNumber,
    required this.tenantName,
    required this.roomRent,
    required this.electricCost,
    required this.waterCost,
    this.commonFee = 300,
    this.otherFee = 0,
    required this.status,
    this.paymentMethod,
    this.paidAt,
    this.slipUrl,
  });

  double get totalAmount => roomRent + electricCost + waterCost + commonFee + otherFee;
  bool get isPaid => status == PaymentStatus.paid;
  bool get isPendingVerification => status == PaymentStatus.pendingVerification;
  bool get isUnpaid => status == PaymentStatus.unpaid;

  RoomBillRecord copyWith({
    String? id,
    String? roomNumber,
    String? tenantName,
    double? roomRent,
    double? electricCost,
    double? waterCost,
    double? commonFee,
    double? otherFee,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? paidAt,
    String? slipUrl,
  }) {
    return RoomBillRecord(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      tenantName: tenantName ?? this.tenantName,
      roomRent: roomRent ?? this.roomRent,
      electricCost: electricCost ?? this.electricCost,
      waterCost: waterCost ?? this.waterCost,
      commonFee: commonFee ?? this.commonFee,
      otherFee: otherFee ?? this.otherFee,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      slipUrl: slipUrl ?? this.slipUrl,
    );
  }

  static List<RoomBillRecord> get sampleRecords => [
        RoomBillRecord(
          id: 'b_101',
          roomNumber: '101',
          tenantName: 'สมชาย ใจดี',
          roomRent: 4500,
          electricCost: 736,
          waterCost: 252,
          commonFee: 300,
          status: PaymentStatus.paid,
          paymentMethod: PaymentMethod.promptpay,
          paidAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RoomBillRecord(
          id: 'b_102',
          roomNumber: '102',
          tenantName: 'วิภาวี สดใส',
          roomRent: 4500,
          electricCost: 640,
          waterCost: 180,
          commonFee: 300,
          status: PaymentStatus.paid,
          paymentMethod: PaymentMethod.bankTransfer,
          paidAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        RoomBillRecord(
          id: 'b_203',
          roomNumber: '203',
          tenantName: 'กนกวรรณ รุ่งเรือง',
          roomRent: 4500,
          electricCost: 816,
          waterCost: 216,
          commonFee: 300,
          status: PaymentStatus.pendingVerification,
          paymentMethod: PaymentMethod.promptpay,
          paidAt: DateTime.now().subtract(const Duration(hours: 3)),
          slipUrl: 'slip_sample.jpg',
        ),
        RoomBillRecord(
          id: 'b_204',
          roomNumber: '204',
          tenantName: 'ธนากร มั่งมี',
          roomRent: 4800,
          electricCost: 920,
          waterCost: 270,
          commonFee: 300,
          status: PaymentStatus.paid,
          paymentMethod: PaymentMethod.cash,
          paidAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        RoomBillRecord(
          id: 'b_305',
          roomNumber: '305',
          tenantName: 'อรุณี สุขเกษม',
          roomRent: 5000,
          electricCost: 1104,
          waterCost: 324,
          commonFee: 300,
          status: PaymentStatus.paid,
          paymentMethod: PaymentMethod.promptpay,
          paidAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RoomBillRecord(
          id: 'b_308',
          roomNumber: '308',
          tenantName: 'ภานุวัชร์ แก้วดี',
          roomRent: 4500,
          electricCost: 560,
          waterCost: 198,
          commonFee: 300,
          status: PaymentStatus.unpaid,
        ),
        RoomBillRecord(
          id: 'b_309',
          roomNumber: '309',
          tenantName: 'ชัชวาล เลิศรัตน์',
          roomRent: 4500,
          electricCost: 680,
          waterCost: 234,
          commonFee: 300,
          status: PaymentStatus.unpaid,
        ),
      ];
}

/// Monthly financial summary
class MonthlyFinancialSummary {
  final String monthLabel;
  final double totalRent;
  final double totalElectric;
  final double totalWater;
  final double totalCommonFee;
  final double totalExpenses;
  final int paidRooms;
  final int pendingVerificationRooms;
  final int unpaidRooms;

  const MonthlyFinancialSummary({
    required this.monthLabel,
    required this.totalRent,
    required this.totalElectric,
    required this.totalWater,
    required this.totalCommonFee,
    required this.totalExpenses,
    required this.paidRooms,
    required this.pendingVerificationRooms,
    required this.unpaidRooms,
  });

  double get totalRevenue => totalRent + totalElectric + totalWater + totalCommonFee;
  double get netProfit => totalRevenue - totalExpenses;
  int get totalBilledRooms => paidRooms + pendingVerificationRooms + unpaidRooms;
  double get collectionRate => totalBilledRooms > 0 ? (paidRooms / totalBilledRooms) * 100 : 0;

  static const MonthlyFinancialSummary currentMonth = MonthlyFinancialSummary(
    monthLabel: 'สิงหาคม 2026',
    totalRent: 202500,
    totalElectric: 32400,
    totalWater: 7200,
    totalCommonFee: 6400,
    totalExpenses: 18200,
    paidRooms: 40,
    pendingVerificationRooms: 2,
    unpaidRooms: 3,
  );
}
