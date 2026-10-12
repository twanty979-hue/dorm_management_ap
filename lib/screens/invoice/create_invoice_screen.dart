import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import 'widgets/digital_receipt_preview_modal.dart';
import 'widgets/invoice_summary_card.dart';
import 'widgets/invoice_utility_card.dart';

/// Apple iOS-styled Create Invoice Screen connected to Supabase Database
class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _tenantsWithLease = [];

  String _selectedRoom = '101';
  String _selectedTenant = 'ผู้เช่า';
  int _rentPrice = 4500;
  int _roomId = 1;
  int _tenantId = 1;

  double _prevElectric = 1000.0;
  double _currentElectric = 1080.0;
  double _electricRate = 8.0;

  double _prevWater = 200.0;
  double _currentWater = 215.0;
  double _waterRate = 18.0;

  bool _includeCommonFee = true;
  int _commonFee = 300;

  @override
  void initState() {
    super.initState();
    _loadDataFromDb();
  }

  void _loadDataFromDb() async {
    setState(() => _isLoading = true);

    final tenants = await ApiService.getTenants();
    final metersRes = await ApiService.getMeters();
    final properties = await ApiService.getProperties();

    if (!mounted) return;

    if (properties.isNotEmpty) {
      final p = properties.first;
      _electricRate = ((p['electric_rate'] ?? p['electricRate'] ?? 8.0) as num).toDouble();
      _waterRate = ((p['water_rate'] ?? p['waterRate'] ?? 18.0) as num).toDouble();
      _commonFee = ((p['common_fee'] ?? p['commonFee'] ?? 300) as num).toInt();
    }

    final List<Map<String, dynamic>> metersList = (metersRes['data'] is List)
        ? List<Map<String, dynamic>>.from(metersRes['data'])
        : [];

    if (tenants.isNotEmpty) {
      _tenantsWithLease = tenants;
      _selectTenantIndex(0, metersList);
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _selectTenantIndex(int index, List<Map<String, dynamic>> metersList) {
    if (index >= _tenantsWithLease.length) return;
    final t = _tenantsWithLease[index];

    final rNum = t['roomNumber']?.toString() ?? '101';
    final tName = t['fullName']?.toString() ?? 'ผู้เช่า';
    final rent = ((t['monthlyRent'] ?? 4500) as num).toInt();
    final tId = (t['id'] is int) ? t['id'] as int : (int.tryParse(t['id'].toString()) ?? 1);

    // Look for matching meter reading
    double pElec = 1000.0;
    double cElec = 1080.0;
    double pWater = 200.0;
    double cWater = 215.0;
    int rId = 1;

    for (var m in metersList) {
      if (m['roomNumber']?.toString() == rNum) {
        pElec = ((m['prevElectric'] ?? 1000) as num).toDouble();
        cElec = ((m['currentElectric'] ?? (pElec + 80)) as num).toDouble();
        pWater = ((m['prevWater'] ?? 200) as num).toDouble();
        cWater = ((m['currentWater'] ?? (pWater + 12)) as num).toDouble();
        if (cElec <= pElec) cElec = pElec + 75;
        if (cWater <= pWater) cWater = pWater + 10;
        rId = (m['roomId'] is int) ? m['roomId'] as int : 1;
        break;
      }
    }

    setState(() {
      _selectedRoom = rNum;
      _selectedTenant = tName;
      _rentPrice = rent;
      _roomId = rId;
      _tenantId = tId;
      _prevElectric = pElec;
      _currentElectric = cElec;
      _prevWater = pWater;
      _currentWater = cWater;
      _isLoading = false;
    });
  }

  double get _electricCost =>
      (_currentElectric >= _prevElectric) ? (_currentElectric - _prevElectric) * _electricRate : 0;

  double get _waterCost =>
      (_currentWater >= _prevWater) ? (_currentWater - _prevWater) * _waterRate : 0;

  double get _grandTotal =>
      _rentPrice + _electricCost + _waterCost + (_includeCommonFee ? _commonFee : 0);

  void _submitInvoice() async {
    setState(() => _isSubmitting = true);

    final wUnits = (_currentWater >= _prevWater) ? _currentWater - _prevWater : 0.0;
    final eUnits = (_currentElectric >= _prevElectric) ? _currentElectric - _prevElectric : 0.0;

    final payload = {
      'dormId': 1,
      'roomId': _roomId,
      'tenantId': _tenantId,
      'roomNumber': _selectedRoom,
      'billingMonth': DateTime.now().toIso8601String().substring(0, 7),
      'rentAmount': _rentPrice.toDouble(),
      'waterUnits': wUnits,
      'waterTotal': _waterCost,
      'electricUnits': eUnits,
      'electricTotal': _electricCost,
      'additionalFee': _includeCommonFee ? _commonFee.toDouble() : 0.0,
      'discount': 0.0,
      'grandTotal': _grandTotal,
      'dueDate': DateTime.now().add(const Duration(days: 7)).toIso8601String().substring(0, 10),
    };

    final res = await ApiService.createInvoice(payload);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ออกใบแจ้งหนี้ห้อง $_selectedRoom ($_selectedTenant) ยอดรวม ฿${_grandTotal.toInt()} และบันทึกลง Database สำเร็จ ✅'),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'เกิดข้อผิดพลาดในการออกใบแจ้งหนี้'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'ออกใบแจ้งหนี้',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Colors.black.withAlpha(12),
            height: 0.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Room & Tenant Selector
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
                        const Text(
                          'เลือกห้องและผู้เช่า (จาก Database)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tenantsWithLease.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFECEB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '⚠️ ยังไม่มีผู้เช่าที่มีสัญญาเช่าในระบบ กรุณาทำสัญญาเช่าก่อนออกบิล',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD70015)),
                                ),
                              )
                            : Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _tenantsWithLease.indexWhere((t) => t['roomNumber'] == _selectedRoom) != -1
                                        ? _tenantsWithLease.indexWhere((t) => t['roomNumber'] == _selectedRoom)
                                        : 0,
                                    isExpanded: true,
                                    icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                                    items: List.generate(_tenantsWithLease.length, (idx) {
                                      final t = _tenantsWithLease[idx];
                                      final r = t['roomNumber'] ?? '101';
                                      final n = t['fullName'] ?? 'ผู้เช่า';
                                      return DropdownMenuItem<int>(
                                        value: idx,
                                        child: Text(
                                          'ห้อง $r • $n',
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      );
                                    }),
                                    onChanged: (val) {
                                      if (val != null) {
                                        _selectTenantIndex(val, []);
                                      }
                                    },
                                  ),
                                ),
                              ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ค่าเช่าห้องตามสัญญา:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text(
                              '฿${_rentPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Electricity Card
                  InvoiceUtilityCard(
                    icon: CupertinoIcons.bolt_fill,
                    iconColor: const Color(0xFFD47C38),
                    title: 'ค่าไฟฟ้า',
                    unitName: 'หน่วย',
                    ratePerUnit: _electricRate,
                    prevReading: _prevElectric,
                    currentReading: _currentElectric,
                    onCurrentChanged: (val) {
                      setState(() => _currentElectric = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Water Card
                  InvoiceUtilityCard(
                    icon: CupertinoIcons.drop_fill,
                    iconColor: const Color(0xFF007AFF),
                    title: 'ค่าน้ำประปา',
                    unitName: 'หน่วย',
                    ratePerUnit: _waterRate,
                    prevReading: _prevWater,
                    currentReading: _currentWater,
                    onCurrentChanged: (val) {
                      setState(() => _currentWater = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Common Fee Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(CupertinoIcons.shield_fill, size: 18, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ค่าบริการส่วนกลาง',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              Text(
                                'ขยะ, WiFi, ทำความสะอาด',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '฿$_commonFee',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        CupertinoSwitch(
                          value: _includeCommonFee,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) => setState(() => _includeCommonFee = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Invoice Grand Total Summary Card
                  InvoiceSummaryCard(
                    rentPrice: _rentPrice,
                    electricCost: _electricCost,
                    waterCost: _waterCost,
                    commonFee: _includeCommonFee ? _commonFee : 0,
                    otherFee: 0,
                  ),
                  const SizedBox(height: 20),

                  // Actions Row: Preview & Submit
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _tenantsWithLease.isEmpty
                                ? null
                                : () {
                                    DigitalReceiptPreviewModal.show(
                                      context,
                                      roomNumber: _selectedRoom,
                                      tenantName: _selectedTenant,
                                      billingMonth: DateTime.now().toIso8601String().substring(0, 7),
                                      rentAmount: _rentPrice,
                                      prevElectric: _prevElectric,
                                      currElectric: _currentElectric,
                                      electricRate: _electricRate,
                                      prevWater: _prevWater,
                                      currWater: _currentWater,
                                      waterRate: _waterRate,
                                      commonFee: _includeCommonFee ? _commonFee : 0,
                                      onConfirmSend: _submitInvoice,
                                    );
                                  },
                            icon: const Icon(CupertinoIcons.eye_fill, size: 16),
                            label: const Text(
                              'ดูตัวอย่างบิล',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: (_isSubmitting || _tenantsWithLease.isEmpty) ? null : _submitInvoice,
                            icon: _isSubmitting
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                : const Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 16),
                            label: Text(
                              _isSubmitting ? 'กำลังบันทึก...' : 'ออกบิลและบันทึก',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
