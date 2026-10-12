/// Model representing a tenant in the dormitory with AI Intelligence
class TenantItem {
  final String id;
  final String name;
  final String roomNumber;
  final int floor;
  final String phone;
  final String lineId;
  final String idCardNumber;
  final String startDate;
  final String endDate;
  final int monthlyRent;
  final double depositAmount;
  final bool isExpiringSoon;
  final int aiRiskScore;
  final String aiRiskLevel;
  final String aiSummary;

  const TenantItem({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.floor,
    required this.phone,
    required this.lineId,
    this.idCardNumber = '',
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    this.depositAmount = 9000.0,
    this.isExpiringSoon = false,
    this.aiRiskScore = 95,
    this.aiRiskLevel = 'น่าเชื่อถือสูง',
    this.aiSummary = 'ประวัติการชำระเงินตรงเวลา สัญญาเช่ามีผลสมบูรณ์',
  });
}
