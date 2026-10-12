import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/room_item.dart';
import '../main_navigation_screen.dart';
import 'widgets/add_room_modal.dart';
import 'widgets/room_card.dart';
import 'widgets/room_filter_bar.dart';

/// Full Apple iOS-styled Room Management Screen with Compact Grid View & Live Sync
class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  String _selectedFilter = 'ทั้งหมด';
  String _searchQuery = '';
  int _gridColumns = 3;
  final TextEditingController _searchController = TextEditingController();

  List<RoomItem> _allRooms = [];
  bool _isFetchingLive = false;

  @override
  void initState() {
    super.initState();
    _loadLiveRooms();
  }

  void _loadLiveRooms() async {
    setState(() => _isFetchingLive = true);
    final liveData = await ApiService.getRooms();
    if (!mounted) return;
    if (liveData.isNotEmpty) {
      final List<RoomItem> loaded = liveData.map((map) {
        RoomStatus status = RoomStatus.vacant;
        final s = map['status']?.toString();
        if (s == 'occupied') status = RoomStatus.occupied;
        if (s == 'maintenance') status = RoomStatus.maintenance;

        final rNum = map['room_number']?.toString() ?? map['roomNumber']?.toString() ?? '101';
        final floor = (map['floor'] is int)
            ? map['floor'] as int
            : (int.tryParse(map['floor']?.toString() ?? '1') ?? 1);
        final rType = map['room_type']?.toString() ?? map['roomType']?.toString() ?? 'ห้องแอร์ • เตียงเดี่ยว';
        final tName = map['tenant_name']?.toString() ?? map['tenantName']?.toString();
        final tPhone = map['tenant_phone']?.toString() ?? map['tenantPhone']?.toString();
        final price = map['base_rent_price'] ?? map['baseRentPrice'] ?? 4500;
        final checkIn = map['check_in_date']?.toString() ?? map['checkInDate']?.toString();
        final wRate = (map['water_rate'] != null || map['waterRate'] != null)
            ? ((map['water_rate'] ?? map['waterRate']) as num).toDouble()
            : null;
        final eRate = (map['electric_rate'] != null || map['electricRate'] != null)
            ? ((map['electric_rate'] ?? map['electricRate']) as num).toDouble()
            : null;

        return RoomItem(
          roomNumber: rNum,
          floor: floor,
          roomType: rType,
          status: status,
          monthlyPrice: (price as num).toInt(),
          tenantName: tName,
          tenantPhone: tPhone,
          checkInDate: checkIn,
          waterRate: wRate,
          electricRate: eRate,
        );
      }).toList();

      setState(() {
        _allRooms = loaded;
        _isFetchingLive = false;
      });
    } else {
      setState(() => _isFetchingLive = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RoomItem> get _filteredRooms {
    return _allRooms.where((room) {
      bool matchesFilter = true;
      if (_selectedFilter == 'ชั้น 1') {
        matchesFilter = room.floor == 1;
      } else if (_selectedFilter == 'ชั้น 2') {
        matchesFilter = room.floor == 2;
      } else if (_selectedFilter == 'ชั้น 3') {
        matchesFilter = room.floor == 3;
      } else if (_selectedFilter == 'ห้องว่าง') {
        matchesFilter = room.isVacant;
      } else if (_selectedFilter == 'มีผู้เช่า') {
        matchesFilter = room.isOccupied;
      } else if (_selectedFilter == 'แจ้งซ่อม') {
        matchesFilter = room.isMaintenance;
      }

      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = room.roomNumber.toLowerCase().contains(query) ||
            (room.tenantName?.toLowerCase().contains(query) ?? false) ||
            room.roomType.toLowerCase().contains(query);
      }

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRooms;
    final occupiedCount = _allRooms.where((r) => r.isOccupied).length;
    final vacantCount = _allRooms.where((r) => r.isVacant).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
                );
              }
            },
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
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'จัดการห้องพัก',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (_isFetchingLive) ...[
              const SizedBox(width: 8),
              const CupertinoActivityIndicator(radius: 8),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () {
                AddRoomModal.show(
                  context,
                  onRoomAdded: (newRoom) {
                    setState(() {
                      _allRooms.insert(0, newRoom);
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(120),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.plus,
                  color: AppColors.primary,
                  size: 20,
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Search Input (iOS Spotlight style)
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'ค้นหาเลขห้อง หรือชื่อผู้เช่า...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12.5,
                  ),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Color(0xFF8E8E93),
                    size: 15,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 38),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: Color(0xFF8E8E93),
                            size: 15,
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Horizontal Filter Bar
            RoomFilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: 10),

            // Grid Section Header with View Mode Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'รายการห้อง (${filtered.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $_selectedFilter (ว่าง $vacantCount | เช่า $occupiedCount)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // View Mode Toggle (3-col vs 2-col)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _gridColumns = 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _gridColumns == 3 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _gridColumns == 3
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            CupertinoIcons.square_grid_3x2_fill,
                            size: 15,
                            color: _gridColumns == 3
                                ? AppColors.primary
                                : AppColors.iconDefault,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _gridColumns = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _gridColumns == 2 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _gridColumns == 2
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            CupertinoIcons.square_grid_2x2_fill,
                            size: 15,
                            color: _gridColumns == 2
                                ? AppColors.primary
                                : AppColors.iconDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Compact Responsive Room Grid or Clean Empty State
            if (_isFetchingLive)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(radius: 14),
              )
            else if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_home_work_rounded, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ยังไม่มีข้อมูลห้องพักในระบบ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'กดปุ่ม "+" ด้านบนขวา หรือปุ่มด้านล่างเพื่อเพิ่มห้องแรกของคุณ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        AddRoomModal.show(
                          context,
                          onRoomAdded: (newRoom) {
                            setState(() {
                              _allRooms.insert(0, newRoom);
                            });
                          },
                        );
                      },
                      icon: const Icon(CupertinoIcons.plus, size: 16),
                      label: const Text('เพิ่มห้องพักใหม่'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridColumns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: _gridColumns == 3 ? 1.08 : 1.48,
                ),
                itemBuilder: (context, index) {
                  final room = filtered[index];
                  return RoomCard(
                    room: room,
                    isCompact3Col: _gridColumns == 3,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
