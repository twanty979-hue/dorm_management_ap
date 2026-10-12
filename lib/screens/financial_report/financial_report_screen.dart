import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/financial_report_model.dart';
import 'widgets/financial_filter_bar.dart';
import 'widgets/financial_kpi_card.dart';
import 'widgets/monthly_trend_chart_card.dart';
import 'widgets/revenue_breakdown_card.dart';
import 'widgets/transaction_card.dart';

/// Full Apple iOS-styled Financial Report Screen with Live Supabase Database Sync
class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  String _selectedMonth = 'รอบปัจจุบัน';
  String _selectedFilter = 'ทั้งหมด';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _months = [
    'รอบปัจจุบัน',
    'สิงหาคม 2026',
    'กรกฎาคม 2026',
    'มิถุนายน 2026',
  ];

  List<RoomBillRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveInvoices();
  }

  void _loadLiveInvoices() async {
    setState(() => _isLoading = true);
    final invoices = await ApiService.getInvoices();
    if (!mounted) return;

    if (invoices.isNotEmpty) {
      final loaded = invoices.map((inv) {
        PaymentStatus status = PaymentStatus.unpaid;
        final st = inv['status']?.toString();
        if (st == 'paid') status = PaymentStatus.paid;
        if (st == 'pending_verification') status = PaymentStatus.pendingVerification;

        return RoomBillRecord(
          id: inv['id']?.toString() ?? '1',
          roomNumber: inv['roomNumber']?.toString() ?? '101',
          tenantName: inv['tenantName']?.toString() ?? 'ผู้เช่า',
          roomRent: ((inv['rentAmount'] ?? 4500) as num).toDouble(),
          electricCost: ((inv['electricTotal'] ?? 0) as num).toDouble(),
          waterCost: ((inv['waterTotal'] ?? 0) as num).toDouble(),
          commonFee: ((inv['additionalFee'] ?? 300) as num).toDouble(),
          otherFee: 0,
          status: status,
        );
      }).toList();

      setState(() {
        _records = loaded;
        _isLoading = false;
      });
    } else {
      // Fallback if no invoices exist yet in DB
      setState(() {
        _records = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateRecord(RoomBillRecord updated) async {
    setState(() {
      final index = _records.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _records[index] = updated;
      }
    });

    final invId = int.tryParse(updated.id);
    if (invId != null) {
      final newStatus = updated.status == PaymentStatus.paid ? 'paid' : (updated.status == PaymentStatus.pendingVerification ? 'pending_verification' : 'unpaid');
      await ApiService.updateInvoiceStatus(invId, newStatus);
    }
  }

  List<RoomBillRecord> get _filteredRecords {
    return _records.where((r) {
      bool matchesFilter = true;
      if (_selectedFilter == 'ชำระแล้ว') {
        matchesFilter = r.status == PaymentStatus.paid;
      } else if (_selectedFilter == 'รอตรวจสลิป') {
        matchesFilter = r.status == PaymentStatus.pendingVerification;
      } else if (_selectedFilter == 'ค้างชำระ') {
        matchesFilter = r.status == PaymentStatus.unpaid;
      }

      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matchesSearch = r.roomNumber.toLowerCase().contains(q) ||
            r.tenantName.toLowerCase().contains(q);
      }

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _onExportReport() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('ส่งออกรายงานการเงิน ($_selectedMonth)'),
        message: const Text('เลือกรูปแบบไฟล์ที่ต้องการดาวน์โหลด'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งออกรายงานเป็นไฟล์ PDF สำเร็จ (financial_report.pdf)'),
                  backgroundColor: Color(0xFF34C759),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('ส่งออกเป็น PDF Report (.pdf)'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งออกรายงานเป็นไฟล์ Excel สำเร็จ (financial_report.xlsx)'),
                  backgroundColor: Color(0xFF34C759),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('ส่งออกเป็น Excel Spreadsheet (.xlsx)'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;

    final totalRentRevenue = _records.where((r) => r.isPaid).fold(0.0, (sum, r) => sum + r.roomRent);
    final totalElectricRevenue = _records.where((r) => r.isPaid).fold(0.0, (sum, r) => sum + r.electricCost);
    final totalWaterRevenue = _records.where((r) => r.isPaid).fold(0.0, (sum, r) => sum + r.waterCost);
    final totalCommonRevenue = _records.where((r) => r.isPaid).fold(0.0, (sum, r) => sum + r.commonFee);

    final summary = MonthlyFinancialSummary(
      monthLabel: _selectedMonth,
      totalRent: totalRentRevenue,
      totalElectric: totalElectricRevenue,
      totalWater: totalWaterRevenue,
      totalCommonFee: totalCommonRevenue,
      totalExpenses: 0,
      paidRooms: _records.where((r) => r.isPaid).length,
      pendingVerificationRooms: _records.where((r) => r.isPendingVerification).length,
      unpaidRooms: _records.where((r) => r.isUnpaid).length,
    );

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
                'รายงานการเงิน',
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
            child: GestureDetector(
              onTap: _onExportReport,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withAlpha(8)),
                ),
                child: Row(
                  children: const [
                    Icon(CupertinoIcons.share_up, size: 14, color: AppColors.textPrimary),
                    SizedBox(width: 4),
                    Text(
                      'ส่งออก',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
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
            // Month Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.calendar, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'เลือกรอบบิล:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      items: _months.map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMonth = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Financial KPI Dashboard Card
            FinancialKpiCard(summary: summary),
            const SizedBox(height: 14),

            // Monthly Trend Chart Card
            const MonthlyTrendChartCard(),
            const SizedBox(height: 14),

            // Revenue Breakdown Card
            RevenueBreakdownCard(summary: summary),
            const SizedBox(height: 16),

            // Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
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
            FinancialFilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: 16),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'รายการบิลทั้งหมด (${filtered.length})',
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
              ],
            ),
            const SizedBox(height: 12),

            // Transaction Cards List
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
                      child: const Icon(CupertinoIcons.doc_text_search, size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ยังไม่มีใบแจ้งหนี้ในรอบบิลนี้',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'เมื่อออกใบแจ้งหนี้แล้ว รายการจะแสดงที่นี่เพื่อตรวจสอบสลิปและบันทึกรายรับ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
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
                  return TransactionCard(
                    record: filtered[index],
                    onUpdate: _updateRecord,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
