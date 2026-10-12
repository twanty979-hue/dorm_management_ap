/// Model representing a room's electricity and water meter record
class MeterItem {
  final int roomId;
  final String roomNumber;
  final String tenantName;
  final int floor;
  final double prevElectric;
  final double? currentElectric;
  final double prevWater;
  final double? currentWater;
  final double electricRate;
  final double waterRate;
  final bool isRecorded;
  final bool isOccupied;

  const MeterItem({
    required this.roomId,
    required this.roomNumber,
    required this.tenantName,
    required this.floor,
    required this.prevElectric,
    this.currentElectric,
    required this.prevWater,
    this.currentWater,
    this.electricRate = 8.0,
    this.waterRate = 18.0,
    this.isRecorded = false,
    this.isOccupied = true,
  });

  double get electricUnitsUsed =>
      (currentElectric != null && currentElectric! >= prevElectric)
          ? (currentElectric! - prevElectric)
          : 0.0;

  double get waterUnitsUsed =>
      (currentWater != null && currentWater! >= prevWater)
          ? (currentWater! - prevWater)
          : 0.0;

  double get electricCost => electricUnitsUsed * electricRate;
  double get waterCost => waterUnitsUsed * waterRate;
  double get totalUtilityCost => electricCost + waterCost;

  factory MeterItem.fromJson(Map<String, dynamic> json) {
    final curElec = json['currentElectric'] ?? json['current_electric'];
    final curWater = json['currentWater'] ?? json['current_water'];

    return MeterItem(
      roomId: (json['roomId'] ?? json['room_id'] ?? 1) as int,
      roomNumber: (json['roomNumber'] ?? json['room_number'] ?? '101').toString(),
      tenantName: (json['tenantName'] ?? json['tenant_name'] ?? 'ผู้เช่า').toString(),
      floor: (json['floor'] is int)
          ? json['floor'] as int
          : (int.tryParse(json['floor']?.toString() ?? '1') ?? 1),
      prevElectric: ((json['prevElectric'] ?? json['prev_electric'] ?? 1000) as num).toDouble(),
      currentElectric: curElec != null && (curElec as num) > 0 ? curElec.toDouble() : null,
      prevWater: ((json['prevWater'] ?? json['prev_water'] ?? 200) as num).toDouble(),
      currentWater: curWater != null && (curWater as num) > 0 ? curWater.toDouble() : null,
      electricRate: ((json['electricRate'] ?? json['electric_rate'] ?? 8.0) as num).toDouble(),
      waterRate: ((json['waterRate'] ?? json['water_rate'] ?? 18.0) as num).toDouble(),
      isRecorded: (json['isRecorded'] ?? json['is_recorded'] ?? false) as bool,
      isOccupied: (json['isOccupied'] ?? json['is_occupied'] ?? true) as bool,
    );
  }

  MeterItem copyWith({
    double? currentElectric,
    double? currentWater,
    bool? isRecorded,
  }) {
    return MeterItem(
      roomId: roomId,
      roomNumber: roomNumber,
      tenantName: tenantName,
      floor: floor,
      prevElectric: prevElectric,
      currentElectric: currentElectric ?? this.currentElectric,
      prevWater: prevWater,
      currentWater: currentWater ?? this.currentWater,
      electricRate: electricRate,
      waterRate: waterRate,
      isRecorded: isRecorded ?? this.isRecorded,
      isOccupied: isOccupied,
    );
  }
}
