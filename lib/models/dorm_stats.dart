/// Model representing dormitory overview and statistics
class DormStats {
  final int vacantRooms;
  final int totalRooms;
  final int totalTenants;
  final int pendingRepairsCount;

  const DormStats({
    this.vacantRooms = 5,
    this.totalRooms = 50,
    this.totalTenants = 45,
    this.pendingRepairsCount = 3,
  });

  int get occupiedRooms => totalRooms - vacantRooms;
  double get occupancyRate => (occupiedRooms / totalRooms) * 100;
}
