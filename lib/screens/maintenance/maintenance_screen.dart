import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/maintenance_item.dart';
import 'widgets/add_maintenance_modal.dart';
import 'widgets/maintenance_card.dart';
import 'widgets/maintenance_filter_bar.dart';
import 'widgets/maintenance_stat_header.dart';

/// Full Apple iOS styled Maintenance Screen with Clean State & Live Sync
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  String _selectedFilter = 'ทั้งหมด';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<MaintenanceItem> _tickets = [];
  bool _isFetchingLive = false;

  @override
  void initState() {
    super.initState();
    _loadLiveMaintenance();
  }

  void _loadLiveMaintenance() async {
    setState(() => _isFetchingLive = true);
    final liveData = await ApiService.getMaintenanceTickets();
    if (!mounted) return;
    if (liveData.isNotEmpty) {
      final List<MaintenanceItem> loaded = liveData.map((map) {
        MaintenanceStatus status = MaintenanceStatus.pending;
        final s = map['status']?.toString();
        if (s == 'in_progress') status = MaintenanceStatus.inProgress;
        if (s == 'completed') status = MaintenanceStatus.completed;

        MaintenancePriority priority = MaintenancePriority.normal;
        final p = map['priority']?.toString();
        if (p == 'urgent') priority = MaintenancePriority.urgent;
        if (p == 'low') priority = MaintenancePriority.low;

        final rNum = map['roomNumber']?.toString() ?? map['room_number']?.toString() ?? map['room_id']?.toString() ?? '101';
        final repName = map['reporterName']?.toString() ?? map['reporter_name']?.toString() ?? 'ผู้เช่า';
        final repPhone = map['reporterPhone']?.toString() ?? map['reporter_phone']?.toString() ?? '081-000-0000';

        return MaintenanceItem(
          id: map['id']?.toString() ?? '1',
          roomNumber: rNum,
          title: map['title']?.toString() ?? 'แจ้งซ่อม',
          description: map['description']?.toString() ?? '',
          status: status,
          priority: priority,
          reportedAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
          reporterName: repName,
          reporterPhone: repPhone,
          technicianName: map['technician_name']?.toString() ?? map['technicianName']?.toString(),
        );
      }).toList();

      setState(() {
        _tickets = loaded;
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

  void _addTicket(MaintenanceItem newItem) {
    setState(() {
      _tickets.insert(0, newItem);
    });
  }

  void _updateTicket(MaintenanceItem updated) {
    setState(() {
      final index = _tickets.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tickets[index] = updated;
      }
    });
  }

  List<MaintenanceItem> get _filteredTickets {
    return _tickets.where((item) {
      bool matchesFilter = true;
      if (_selectedFilter == 'รอดำเนินการ') {
        matchesFilter = item.status == MaintenanceStatus.pending;
      } else if (_selectedFilter == 'กำลังทำ') {
        matchesFilter = item.status == MaintenanceStatus.inProgress;
      } else if (_selectedFilter == 'เสร็จสิ้น') {
        matchesFilter = item.status == MaintenanceStatus.completed;
      } else if (_selectedFilter == 'ด่วนมาก') {
        matchesFilter = item.priority == MaintenancePriority.urgent;
      }

      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = item.roomNumber.toLowerCase().contains(query) ||
            item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            (item.technicianName?.toLowerCase().contains(query) ?? false) ||
            item.reporterName.toLowerCase().contains(query);
      }

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTickets;
    final total = _tickets.length;
    final pending = _tickets.where((t) => t.status == MaintenanceStatus.pending).length;
    final inProgress = _tickets.where((t) => t.status == MaintenanceStatus.inProgress).length;
    final completed = _tickets.where((t) => t.status == MaintenanceStatus.completed).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? Padding(
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
              )
            : null,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'รายการแจ้งซ่อม',
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
              const CupertinoActivityIndicator(radius: 7),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddMaintenanceModal(onAdd: _addTicket),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  hintText: 'ค้นหาเลขห้อง, อาการ, ช่างผู้รับผิดชอบ...',
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

            // Stat Summary Header
            MaintenanceStatHeader(
              total: total,
              pending: pending,
              inProgress: inProgress,
              completed: completed,
            ),
            const SizedBox(height: 14),

            // Horizontal Filter Bar
            MaintenanceFilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (f) => setState(() => _selectedFilter = f),
            ),
            const SizedBox(height: 16),

            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'รายการงาน (${filtered.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Text(
                  'สถานะ: $_selectedFilter',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cards List or Clean Empty State
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
                        color: const Color(0xFFFFECEB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.wrench_fill, size: 40, color: Color(0xFFFF3B30)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ไม่มีรายการแจ้งซ่อมในระบบ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'กดปุ่มด้านล่างเพื่อสร้างใบแจ้งซ่อมใหม่',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AddMaintenanceModal(onAdd: _addTicket),
                        );
                      },
                      icon: const Icon(CupertinoIcons.plus, size: 16),
                      label: const Text('สร้างใบแจ้งซ่อมใหม่'),
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ticket = filtered[index];
                  return MaintenanceCard(
                    item: ticket,
                    onUpdate: _updateTicket,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
