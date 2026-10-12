import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/tenant_item.dart';

/// Apple iOS-styled Modal Sheet for adding a new tenant with strict phone/ID card validation & live DB rooms
class AddTenantModal extends StatefulWidget {
  final Function(TenantItem) onTenantAdded;

  const AddTenantModal({
    super.key,
    required this.onTenantAdded,
  });

  static void show(BuildContext context, {required Function(TenantItem) onTenantAdded}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTenantModal(onTenantAdded: onTenantAdded),
    );
  }

  @override
  State<AddTenantModal> createState() => _AddTenantModalState();
}

class _AddTenantModalState extends State<AddTenantModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idCardController = TextEditingController();
  final _depositController = TextEditingController(text: '9000');
  final _rentController = TextEditingController(text: '4500');
  final _waterRateController = TextEditingController(text: '5.0');
  final _electricRateController = TextEditingController(text: '10.0');
  double _dormDefaultWater = 5.0;
  double _dormDefaultElectric = 10.0;
  bool _isLoading = false;
  bool _isFetchingRooms = true;
  String? _errorMessage;

  String? _selectedRoom;
  List<Map<String, dynamic>> _dbVacantRooms = [];
  String _contractDuration = '1 ปี (12 เดือน)';
  final List<String> _durations = ['3 เดือน', '6 เดือน', '1 ปี (12 เดือน)', '2 ปี'];

  @override
  void initState() {
    super.initState();
    _loadVacantRoomsFromDb();
  }

  void _updateRatesFromRoom(Map<String, dynamic> room) {
    final w = room['water_rate'] ?? room['waterRate'];
    final e = room['electric_rate'] ?? room['electricRate'];
    final wVal = (w != null && (w is num) && w > 0) ? w.toDouble() : _dormDefaultWater;
    final eVal = (e != null && (e is num) && e > 0) ? e.toDouble() : _dormDefaultElectric;
    _waterRateController.text = wVal.toString();
    _electricRateController.text = eVal.toString();
  }

  void _loadVacantRoomsFromDb() async {
    setState(() => _isFetchingRooms = true);

    // 1. Fetch default rates from dorm properties
    try {
      final properties = await ApiService.getProperties();
      if (properties.isNotEmpty) {
        final prop = properties.first;
        final w = prop['water_rate'] ?? prop['waterRate'];
        final e = prop['electric_rate'] ?? prop['electricRate'];
        if (w != null && (w is num)) _dormDefaultWater = w.toDouble();
        if (e != null && (e is num)) _dormDefaultElectric = e.toDouble();
      }
    } catch (_) {}

    var rooms = await ApiService.getRooms(status: 'vacant');
    if (rooms.isEmpty) {
      final all = await ApiService.getRooms();
      rooms = all
          .where((r) =>
              r['status'] == 'vacant' ||
              r['status'] == null ||
              r['status'] == '' ||
              r['status'] == 'ห้องว่าง')
          .toList();
      if (rooms.isEmpty && all.isNotEmpty) {
        rooms = all;
      }
    }
    if (!mounted) return;

    // Deduplicate rooms by room_number
    final Map<String, Map<String, dynamic>> uniqueMap = {};
    for (var r in rooms) {
      final rNum = r['room_number']?.toString() ?? r['roomNumber']?.toString() ?? '';
      if (rNum.isNotEmpty && !uniqueMap.containsKey(rNum)) {
        uniqueMap[rNum] = r;
      }
    }

    final distinct = uniqueMap.values.toList();

    if (distinct.isNotEmpty) {
      setState(() {
        _dbVacantRooms = distinct;
        final firstRoom = distinct.first;
        _selectedRoom = firstRoom['room_number']?.toString() ?? firstRoom['roomNumber']?.toString();
        final rent = firstRoom['base_rent_price'] ?? firstRoom['baseRentPrice'] ?? 4500;
        final deposit = firstRoom['deposit_amount'] ?? firstRoom['depositAmount'] ?? 9000;
        _rentController.text = rent.toString();
        _depositController.text = deposit.toString();
        _updateRatesFromRoom(firstRoom);
        _isFetchingRooms = false;
      });
    } else {
      setState(() {
        _dbVacantRooms = [];
        _selectedRoom = null;
        _waterRateController.text = _dormDefaultWater.toString();
        _electricRateController.text = _dormDefaultElectric.toString();
        _isFetchingRooms = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _depositController.dispose();
    _rentController.dispose();
    _waterRateController.dispose();
    _electricRateController.dispose();
    super.dispose();
  }

  // 🤖 AI OCR Auto-Fill Simulation
  void _triggerAiOcrScan() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('🤖 AI ผู้ช่วยอ่านข้อมูลบัตรประชาชน (Smart OCR)'),
        message: const Text('จำลองการสแกนบัตรประชาชนจริง: ดึงชื่อ เลข 13 หลัก และเบอร์โทร 10 หลัก'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.text = 'คุณวิศรุต วงศ์เจริญ';
                _phoneController.text = '0899887766';
                _idCardController.text = '1100500987654';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✨ AI สแกนและกรอกข้อมูลบัตรประชาชนครบ 13 หลักสำเร็จแล้ว'),
                  backgroundColor: Color(0xFF7B61FF),
                ),
              );
            },
            child: const Text('สแกนบัตร: คุณวิศรุต วงศ์เจริญ'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.text = 'คุณพิมพ์ลภัส ธรรมรักษา';
                _phoneController.text = '0814455667';
                _idCardController.text = '1100400123456';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✨ AI สแกนและกรอกข้อมูลบัตรประชาชนครบ 13 หลักสำเร็จแล้ว'),
                  backgroundColor: Color(0xFF7B61FF),
                ),
              );
            },
            child: const Text('สแกนบัตร: คุณพิมพ์ลภัส ธรรมรักษา'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
      ),
    );
  }

  void _submit() async {
    if (_dbVacantRooms.isEmpty || _selectedRoom == null) {
      setState(() {
        _errorMessage = 'ไม่พบห้องว่างในระบบ Database กรุณาไปเพิ่มห้องพักก่อนทำสัญญา';
      });
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final floor = int.tryParse(_selectedRoom!.substring(0, 1)) ?? 1;
      final deposit = double.tryParse(_depositController.text) ?? 9000.0;
      final rent = double.tryParse(_rentController.text) ?? 4500.0;
      final waterRate = double.tryParse(_waterRateController.text) ?? _dormDefaultWater;
      final electricRate = double.tryParse(_electricRateController.text) ?? _dormDefaultElectric;
      final fullName = 'คุณ${_nameController.text.trim().replaceAll('คุณ', '')}';
      final phone = _phoneController.text.trim();
      final idCard = _idCardController.text.trim();

      // Find selected room ID from DB
      int roomId = 1;
      for (var r in _dbVacantRooms) {
        final rNum = r['room_number']?.toString() ?? r['roomNumber']?.toString();
        if (rNum == _selectedRoom) {
          roomId = (r['id'] is int) ? r['id'] : (int.tryParse(r['id'].toString()) ?? 1);
          break;
        }
      }

      final newTenant = TenantItem(
        id: 'T${DateTime.now().millisecondsSinceEpoch}',
        name: fullName,
        roomNumber: _selectedRoom!,
        floor: floor,
        phone: phone,
        lineId: phone,
        idCardNumber: idCard,
        startDate: '01/04/2026',
        endDate: _contractDuration.contains('6')
            ? '30/09/2026'
            : (_contractDuration.contains('3') ? '30/06/2026' : '31/03/2027'),
        monthlyRent: rent.toInt(),
        depositAmount: deposit,
        isExpiringSoon: false,
        aiRiskScore: 97,
        aiRiskLevel: 'น่าเชื่อถือสูง',
        aiSummary: 'ตรวจสอบข้อมูลบัตรประชาชน 13 หลักและเบอร์โทรศัพท์ 10 หลักเรียบร้อย',
      );

      // 🚀 Send POST /api/v1/leases to Go API / Supabase
      final result = await ApiService.createTenantWithLease(
        tenantData: {
          'fullName': fullName,
          'phone': phone,
          'idCardNumber': idCard,
        },
        leaseData: {
          'roomId': roomId,
          'dormId': 1,
          'startDate': '2026-04-01',
          'endDate': _contractDuration.contains('6')
              ? '2026-09-30'
              : (_contractDuration.contains('3') ? '2026-06-30' : '2027-03-31'),
          'monthlyRent': rent,
          'depositAmount': deposit,
          'waterRate': waterRate,
          'electricRate': electricRate,
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        widget.onTenantAdded(newTenant);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มผู้เช่า $fullName เข้าห้อง $_selectedRoom และบันทึกลง Supabase สำเร็จ'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'ไม่สามารถบันทึกข้อมูลผู้เช่าได้';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guaranteed Deduplication of Vacant Rooms
    final Map<String, Map<String, dynamic>> distinctMap = {};
    for (var r in _dbVacantRooms) {
      final num = r['room_number']?.toString() ?? r['roomNumber']?.toString() ?? '';
      if (num.isNotEmpty && !distinctMap.containsKey(num)) {
        distinctMap[num] = r;
      }
    }
    final List<Map<String, dynamic>> distinctVacantRooms = distinctMap.values.toList();

    final String? safeSelectedRoom = (distinctVacantRooms.any((r) => (r['room_number']?.toString() ?? r['roomNumber']?.toString()) == _selectedRoom))
        ? _selectedRoom
        : (distinctVacantRooms.isNotEmpty ? (distinctVacantRooms.first['room_number']?.toString() ?? distinctVacantRooms.first['roomNumber']?.toString()) : null);

    final String safeDuration = _durations.contains(_contractDuration) ? _contractDuration : _durations[2];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row with AI OCR Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.person_badge_plus_fill,
                            color: Color(0xFF007AFF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'เพิ่มผู้เช่า & ทำสัญญา (DB)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill,
                          color: Color(0xFFC7C7CC), size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),

              // 🤖 AI OCR Action Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3F0FF), Color(0xFFEBF3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF7B61FF).withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF7B61FF), size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI สแกนบัตรประชาชน (Smart OCR)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5B3DE6),
                              ),
                            ),
                            Text(
                              'ดึงเลข 13 หลัก, เบอร์ 10 หลัก และชื่อ กรอกให้อัตโนมัติ',
                              style: TextStyle(fontSize: 11, color: Color(0xFF4A4A68)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _triggerAiOcrScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B61FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('ใช้ AI สแกน', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),

              // Error Banner
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFF3B30).withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_triangle_fill,
                            color: Color(0xFFFF3B30), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD70015),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Tenant Full Name
                      const Text(
                        'ชื่อ - นามสกุล ผู้เช่า *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'เช่น คุณณภัทร วุฒิเดช',
                          filled: true,
                          fillColor: const Color(0xFFF2F2F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกชื่อผู้เช่า';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Phone (10 digits lock) & ID Card (13 digits lock)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phone Field (Strict 10 digits)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'เบอร์โทรศัพท์ (10 หลัก) *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '08XXXXXXXX',
                                    counterText: '',
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'กรุณากรอกเบอร์โทร';
                                    }
                                    if (value.trim().length != 10) {
                                      return 'ต้องครบ 10 หลัก (${value.trim().length}/10)';
                                    }
                                    if (!value.trim().startsWith('0')) {
                                      return 'ต้องขึ้นต้นด้วย 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ID Card (Strict 13 digits)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'บัตรประชาชน (13 หลัก) *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _idCardController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'เลข 13 หลัก',
                                    counterText: '',
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'กรุณากรอกเลขบัตร';
                                    }
                                    if (value.trim().length != 13) {
                                      return 'ต้องครบ 13 หลัก (${value.trim().length}/13)';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Select Room (ONLY from DB) & Contract Duration
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'เลือกห้องพักว่างใน DB *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _isFetchingRooms
                                    ? Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2F2F7),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const CupertinoActivityIndicator(radius: 8),
                                      )
                                    : distinctVacantRooms.isEmpty
                                        ? Container(
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFECEB),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: const Text(
                                              '⚠️ ไม่มีห้องว่างใน DB',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFD70015),
                                              ),
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
                                              child: DropdownButton<String>(
                                                value: safeSelectedRoom,
                                                isExpanded: true,
                                                icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                                                items: distinctVacantRooms.map((room) {
                                                  final roomNum = room['room_number']?.toString() ?? room['roomNumber']?.toString() ?? '101';
                                                  final floor = room['floor'] ?? 1;
                                                  return DropdownMenuItem<String>(
                                                    value: roomNum,
                                                    child: Text(
                                                      'ห้อง $roomNum (ชั้น $floor)',
                                                      style: const TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    setState(() {
                                                      _selectedRoom = val;
                                                      for (var r in distinctVacantRooms) {
                                                        final rNum = r['room_number']?.toString() ?? r['roomNumber']?.toString();
                                                        if (rNum == val) {
                                                          final rent = r['base_rent_price'] ?? r['baseRentPrice'] ?? 4500;
                                                          final deposit = r['deposit_amount'] ?? r['depositAmount'] ?? 9000;
                                                          _rentController.text = rent.toString();
                                                          _depositController.text = deposit.toString();
                                                          _updateRatesFromRoom(r);
                                                          break;
                                                        }
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ระยะเวลาสัญญา',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F2F7),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: safeDuration,
                                      isExpanded: true,
                                      icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                                      items: _durations.map((dur) {
                                        return DropdownMenuItem<String>(
                                          value: dur,
                                          child: Text(
                                            dur,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _contractDuration = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Monthly Rent & Deposit Amount
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ค่าเช่ารายเดือน (฿) *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _rentController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    prefixText: '฿ ',
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'กรุณากรอกค่าเช่า';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'เงินประกันสัญญา (฿)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _depositController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    prefixText: '฿ ',
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Water & Electric Rates for Lease Agreement (Auto-pulled)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F7FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF007AFF).withAlpha(35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: Color(0xFF007AFF)),
                                const SizedBox(width: 6),
                                const Text(
                                  'อัตราค่าน้ำ - ค่าไฟในสัญญาเช่า',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF).withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'ดึงจากห้องพักอัตโนมัติ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(CupertinoIcons.drop_fill, size: 13, color: Color(0xFF007AFF)),
                                          SizedBox(width: 4),
                                          Text(
                                            'ค่าน้ำ (฿/หน่วย)',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _waterRateController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          prefixText: '฿ ',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black.withAlpha(20)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(CupertinoIcons.bolt_fill, size: 13, color: Color(0xFFFF9500)),
                                          SizedBox(width: 4),
                                          Text(
                                            'ค่าไฟ (฿/หน่วย)',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _electricRateController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          prefixText: '฿ ',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black.withAlpha(20)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_isLoading || distinctVacantRooms.isEmpty) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CupertinoActivityIndicator(color: Colors.white)
                              : const Text(
                                  'บันทึกสัญญาและเพิ่มผู้เช่า',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
