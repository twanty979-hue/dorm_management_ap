import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/tenant_item.dart';
import '../main_navigation_screen.dart';
import 'widgets/add_tenant_modal.dart';
import 'widgets/tenant_card.dart';

/// Apple iOS-styled Tenant Management Screen with AI Insights & Live Supabase Sync
class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});

  @override
  State<TenantManagementScreen> createState() => _TenantManagementScreenState();
}

class _TenantManagementScreenState extends State<TenantManagementScreen> {
  String _selectedFilter = 'ทั้งหมด';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<TenantItem> _allTenants = [];
  bool _isFetchingLive = false;

  @override
  void initState() {
    super.initState();
    _loadLiveTenants();
  }

  void _loadLiveTenants() async {
    setState(() => _isFetchingLive = true);
    final liveData = await ApiService.getTenants();
    if (!mounted) return;
    if (liveData.isNotEmpty) {
      final List<TenantItem> loaded = liveData.map((map) {
        return TenantItem(
          id: map['id']?.toString() ?? '1',
          name: map['fullName']?.toString() ?? (map['full_name']?.toString() ?? 'ผู้เช่า'),
          roomNumber: map['roomNumber']?.toString() ?? '101',
          floor: (map['floor'] is int) ? map['floor'] : 1,
          phone: map['phone']?.toString() ?? '081-000-0000',
          lineId: map['lineUserId']?.toString() ?? (map['line_user_id']?.toString() ?? 'line_user'),
          idCardNumber: map['idCardNumber']?.toString() ?? '',
          startDate: map['startDate']?.toString() ?? '01/01/2026',
          endDate: map['endDate']?.toString() ?? '31/12/2026',
          monthlyRent: (map['monthlyRent'] != null)
              ? (map['monthlyRent'] as num).toInt()
              : 4500,
          depositAmount: (map['depositAmount'] != null)
              ? (map['depositAmount'] as num).toDouble()
              : 9000.0,
          isExpiringSoon: map['isExpiringSoon'] == true,
          aiRiskScore: map['aiRiskScore'] ?? 95,
          aiRiskLevel: map['aiRiskLevel']?.toString() ?? 'น่าเชื่อถือสูง',
          aiSummary: map['aiSummary']?.toString() ?? 'ประวัติการชำระเงินตรงเวลา สัญญาเช่ามีผลสมบูรณ์',
        );
      }).toList();

      setState(() {
        _allTenants = loaded;
        _isFetchingLive = false;
      });
    } else {
      setState(() {
        _allTenants = [];
        _isFetchingLive = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TenantItem> get _filteredTenants {
    return _allTenants.where((tenant) {
      bool matchesFilter = true;
      if (_selectedFilter == 'ชั้น 1') {
        matchesFilter = tenant.floor == 1;
      } else if (_selectedFilter == 'ชั้น 2') {
        matchesFilter = tenant.floor == 2;
      } else if (_selectedFilter == 'ชั้น 3') {
        matchesFilter = tenant.floor == 3;
      } else if (_selectedFilter == 'ใกล้หมดสัญญา') {
        matchesFilter = tenant.isExpiringSoon;
      }

      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matchesSearch = tenant.name.toLowerCase().contains(q) ||
            tenant.roomNumber.toLowerCase().contains(q) ||
            tenant.phone.contains(q);
      }

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTenants;

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
                'จัดการผู้เช่า',
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
                AddTenantModal.show(
                  context,
                  onTenantAdded: (newTenant) {
                    setState(() {
                      _allTenants.insert(0, newTenant);
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [


            // Search Input
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
                  hintText: 'ค้นหาชื่อผู้เช่า, เบอร์โทร, หรือเลขห้อง...',
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

            // Summary Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSummaryPill('ผู้เช่าทั้งหมด', '${_allTenants.length} คน', Colors.white, AppColors.textPrimary),
                  const SizedBox(width: 8),
                  _buildSummaryPill('สัญญาปกติ', '${_allTenants.where((t) => !t.isExpiringSoon).length} คน', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  _buildSummaryPill('ใกล้หมดสัญญา', '${_allTenants.where((t) => t.isExpiringSoon).length} คน', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['ทั้งหมด', 'ชั้น 1', 'ชั้น 2', 'ชั้น 3', 'ใกล้หมดสัญญา'].map((filter) {
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

            // List of Tenants
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'รายชื่อผู้เช่า (${filtered.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
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
                        color: const Color(0xFFEBF3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.person_badge_plus_fill, size: 40, color: Color(0xFF007AFF)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ยังไม่มีรายชื่อผู้เช่าในระบบ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'กดปุ่มด้านล่างเพื่อทำสัญญาและเพิ่มผู้เช่าคนแรกด้วย AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        AddTenantModal.show(
                          context,
                          onTenantAdded: (newTenant) {
                            setState(() {
                              _allTenants.insert(0, newTenant);
                            });
                          },
                        );
                      },
                      icon: const Icon(CupertinoIcons.plus, size: 16),
                      label: const Text('ทำสัญญาและเพิ่มผู้เช่า'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
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
                  final tenant = filtered[index];
                  return TenantCard(tenant: tenant);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String label, String count, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
