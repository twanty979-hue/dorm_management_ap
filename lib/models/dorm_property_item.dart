/// Model representing a dormitory property / branch in Multi-property SaaS
class DormPropertyItem {
  final String id;
  final String name;
  final String address;
  final int totalRooms;
  final int occupiedRooms;
  final int monthlyRevenue;
  final String electricRate;
  final String waterRate;
  final bool isMainBranch;

  const DormPropertyItem({
    required this.id,
    required this.name,
    required this.address,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.monthlyRevenue,
    required this.electricRate,
    required this.waterRate,
    this.isMainBranch = false,
  });

  int get vacantRooms => totalRooms - occupiedRooms;
  int get occupancyRate => ((occupiedRooms / totalRooms) * 100).round();

  static List<DormPropertyItem> get sampleProperties => [
        const DormPropertyItem(
          id: 'prop_01',
          name: 'The Green Residence',
          address: '128/4 ซอยสุขุมวิท 101, บางนา, กทม.',
          totalRooms: 50,
          occupiedRooms: 45,
          monthlyRevenue: 248500,
          electricRate: '8.0 ฿/หน่วย',
          waterRate: '18.0 ฿/หน่วย',
          isMainBranch: true,
        ),
        const DormPropertyItem(
          id: 'prop_02',
          name: 'Green Place รัชดา',
          address: '88 ซอยรัชดาภิเษก 32, จตุจักร, กทม.',
          totalRooms: 36,
          occupiedRooms: 34,
          monthlyRevenue: 185000,
          electricRate: '8.0 ฿/หน่วย',
          waterRate: '18.0 ฿/หน่วย',
        ),
        const DormPropertyItem(
          id: 'prop_03',
          name: 'The Green Mansion ศาลายา',
          address: '45/12 ถนนพุทธมณฑลสาย 4, นครปฐม',
          totalRooms: 60,
          occupiedRooms: 58,
          monthlyRevenue: 295000,
          electricRate: '7.5 ฿/หน่วย',
          waterRate: '17.0 ฿/หน่วย',
        ),
      ];
}
