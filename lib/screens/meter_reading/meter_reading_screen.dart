import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/meter_item.dart';
import '../room_management/room_management_screen.dart';
import 'widgets/meter_entry_card.dart';

/// Full Apple iOS-styled Meter Reading Screen connected to Go Backend & Supabase
class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  String _selectedFilter = 'ทั้งหมด';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<MeterItem> _allMeters = [];
  bool _isLoading = true;
  bool _isSavingBatch = false;
  double _electricRate = 8.0;
  double _waterRate = 18.0;

  @override
  void initState() {
    super.initState();
    _loadLiveMeters();
  }

  void _loadLiveMeters() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getMeters();
    if (!mounted) return;

    if (res['success'] == true && res['data'] is List) {
      final List<Map<String, dynamic>> rawList = List<Map<String, dynamic>>.from(res['data']);
      final rates = res['rates'] as Map<String, dynamic>?;
      if (rates != null) {
        _electricRate = ((rates['electricRate'] ?? 8.0) as num).toDouble();
        _waterRate = ((rates['waterRate'] ?? 18.0) as num).toDouble();
      }

      final meters = rawList.map((m) => MeterItem.fromJson(m)).toList();
      setState(() {
        _allMeters = meters;
        _isLoading = false;
      });
    } else {
      // Fallback: load directly from rooms table if meter endpoint has no data yet
      final rooms = await ApiService.getRooms();
      if (!mounted) return;
      final meters = rooms.map((r) {
        final rId = (r['id'] is int) ? r['id'] : (int.tryParse(r['id'].toString()) ?? 1);
        final rNum = r['room_number']?.toString() ?? r['roomNumber']?.toString() ?? '101';
        final fl = (r['floor'] is int) ? r['floor'] : (int.tryParse(r['floor']?.toString() ?? '1') ?? 1);
        final isOcc = r['status'] == 'occupied';

        return MeterItem(
          roomId: rId,
          roomNumber: rNum,
          tenantName: isOcc ? 'ผู้เช่าห้อง $rNum' : 'ห้องว่าง (ไม่มีผู้เช่า)',
          floor: fl,
          prevElectric: 1000.0 + (rId * 120),
          prevWater: 200.0 + (rId * 25),
          electricRate: _electricRate,
          waterRate: _waterRate,
          isRecorded: false,
          isOccupied: isOcc,
        );
      }).toList();

      setState(() {
        _allMeters = meters;
        _isLoading = false;
      });
    }
  }

  void _saveSingleRoom(int index, double curElec, double curWater) async {
    final meter = _allMeters[index];
    setState(() {
      _allMeters[index] = meter.copyWith(
        currentElectric: curElec,
        currentWater: curWater,
        isRecorded: true,
      );
    });

    // Send single room save to API
    await ApiService.recordMeters([
      {
        'roomId': meter.roomId,
        'prevElectric': meter.prevElectric,
        'currentElectric': curElec,
        'prevWater': meter.prevWater,
        'currentWater': curWater,
      }
    ]);
  }

  void _saveAllMeters() async {
    if (_allMeters.isEmpty) return;

    setState(() => _isSavingBatch = true);

    final List<Map<String, dynamic>> payload = _allMeters.map((m) {
      return {
        'roomId': m.roomId,
        'prevElectric': m.prevElectric,
        'currentElectric': m.currentElectric ?? m.prevElectric,
        'prevWater': m.prevWater,
        'currentWater': m.currentWater ?? m.prevWater,
      };
    }).toList();

    final res = await ApiService.recordMeters(payload);

    if (!mounted) return;
    setState(() {
      _isSavingBatch = false;
      _allMeters = _allMeters.map((m) => m.copyWith(isRecorded: true)).toList();
    });

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกมิเตอร์ ${_allMeters.length} ห้องลงฐานข้อมูล Supabase สำเร็จ ✅'),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'เกิดข้อผิดพลาดในการบันทึก'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MeterItem> get _filteredMeters {
    return _allMeters.where((item) {
      bool matchesFilter = true;
      if (_selectedFilter == 'ยังไม่ได้จด') {
        matchesFilter = !item.isRecorded;
      } else if (_selectedFilter == 'จดแล้ว') {
        matchesFilter = item.isRecorded;
      } else if (_selectedFilter == 'มีผู้เช่า') {
        matchesFilter = item.isOccupied;
      } else if (_selectedFilter == 'ชั้น 1') {
        matchesFilter = item.floor == 1;
      } else if (_selectedFilter == 'ชั้น 2') {
        matchesFilter = item.floor == 2;
      } else if (_selectedFilter == 'ชั้น 3') {
        matchesFilter = item.floor == 3;
      }

      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matchesSearch = item.roomNumber.toLowerCase().contains(q) ||
            item.tenantName.toLowerCase().contains(q);
      }

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMeters;
    final totalRooms = _allMeters.length;
    final recordedRooms = _allMeters.where((m) => m.isRecorded).length;
    final progress = totalRooms > 0 ? (recordedRooms / totalRooms) : 0.0;
    final progressPercent = (progress * 100).toInt();

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
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'จดเลขมิเตอร์',
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
            if (_isLoading) ...[
              const SizedBox(width: 8),
              const CupertinoActivityIndicator(radius: 7),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton(
              onPressed: (_isSavingBatch || _allMeters.isEmpty) ? null : _saveAllMeters,
              child: _isSavingBatch
                  ? const CupertinoActivityIndicator(radius: 8)
                  : const Text(
                      'บันทึกทั้งหมด',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
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
            // Month Cycle & Progress Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.calendar, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'รอบบิล: ${_getCurrentMonthName()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ไฟ ${_electricRate.toStringAsFixed(0)}฿ • น้ำ ${_waterRate.toStringAsFixed(0)}฿',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ความคืบหน้าการจดมิเตอร์',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$recordedRooms / $totalRooms ห้อง ($progressPercent%)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF2F2F7),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'ค้นหาเลขห้อง หรือชื่อผู้เช่า...',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: AppColors.iconDefault,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(CupertinoIcons.clear_circled_solid,
                              color: Color(0xFFC7C7CC), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['ทั้งหมด', 'ยังไม่ได้จด', 'จดแล้ว', 'มีผู้เช่า', 'ชั้น 1', 'ชั้น 2', 'ชั้น 3'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.black.withAlpha(10),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Section Header
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
                      '• $_selectedFilter',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ค่าน้ำ ${_waterRate.toInt()}฿ | ค่าไฟ ${_electricRate.toInt()}฿',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content List or Empty State
            if (_isLoading)
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
                      child: const Icon(CupertinoIcons.bolt_slash_fill, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ยังไม่มีห้องพักสำหรับจดมิเตอร์',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'กรุณาเพิ่มห้องพักในระบบก่อนเพื่อเริ่มจดมิเตอร์น้ำ-ไฟ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const RoomManagementScreen()),
                        ).then((_) => _loadLiveMeters());
                      },
                      icon: const Icon(CupertinoIcons.plus, size: 16),
                      label: const Text('ไปที่หน้าจัดการห้องพัก'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final originalIndex = _allMeters.indexOf(item);
                  return MeterEntryCard(
                    item: item,
                    onSave: (curElec, curWater) {
                      if (originalIndex != -1) {
                        _saveSingleRoom(originalIndex, curElec, curWater);
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getCurrentMonthName() {
    const thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final now = DateTime.now();
    final monthName = thaiMonths[now.month - 1];
    final thaiYear = now.year + 543;
    return '$monthName $thaiYear';
  }
}
