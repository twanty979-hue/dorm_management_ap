import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/room_item.dart';

/// Apple iOS-styled Modal Sheet for adding a new room with strict API verification
class AddRoomModal extends StatefulWidget {
  final Function(RoomItem) onRoomAdded;

  const AddRoomModal({
    super.key,
    required this.onRoomAdded,
  });

  static void show(BuildContext context, {required Function(RoomItem) onRoomAdded}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddRoomModal(onRoomAdded: onRoomAdded),
    );
  }

  @override
  State<AddRoomModal> createState() => _AddRoomModalState();
}

class _AddRoomModalState extends State<AddRoomModal> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController(text: '4500');
  final _depositController = TextEditingController(text: '9000');
  final _waterRateController = TextEditingController(text: '5.0');
  final _electricRateController = TextEditingController(text: '10.0');
  bool _isLoading = false;
  String? _errorMessage;

  int _selectedFloor = 1;
  String _selectedRoomType = 'ห้องแอร์ • เตียงเดี่ยว';
  final List<String> _amenities = ['แอร์', 'เครื่องทำน้ำอุ่น', 'เตียง 5 ฟุต', 'ตู้เสื้อผ้า', 'WiFi'];
  final Set<String> _selectedAmenities = {'แอร์', 'เครื่องทำน้ำอุ่น', 'เตียง 5 ฟุต', 'ตู้เสื้อผ้า', 'WiFi'};

  final List<String> _roomTypes = [
    'ห้องแอร์ • เตียงเดี่ยว',
    'ห้องแอร์ • เตียงคู่',
    'ห้องพัดลม • เตียงเดี่ยว',
    'ห้องแอร์ VIP • ระเบียงกว้าง',
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultRates();
  }

  Future<void> _loadDefaultRates() async {
    try {
      final properties = await ApiService.getProperties();
      if (properties.isNotEmpty) {
        final prop = properties.first;
        final wRate = prop['water_rate'] ?? prop['waterRate'];
        final eRate = prop['electric_rate'] ?? prop['electricRate'];
        if (mounted) {
          setState(() {
            if (wRate != null) {
              _waterRateController.text = wRate.toString();
            }
            if (eRate != null) {
              _electricRateController.text = eRate.toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not load default rates: $e');
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _waterRateController.dispose();
    _electricRateController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final price = int.tryParse(_priceController.text) ?? 4500;
      final deposit = double.tryParse(_depositController.text) ?? 9000.0;
      final waterRate = double.tryParse(_waterRateController.text) ?? 5.0;
      final electricRate = double.tryParse(_electricRateController.text) ?? 10.0;
      final roomNum = _roomNumberController.text.trim();

      final newRoom = RoomItem(
        roomNumber: roomNum,
        floor: _selectedFloor,
        roomType: _selectedRoomType,
        monthlyPrice: price,
        status: RoomStatus.vacant,
        waterRate: waterRate,
        electricRate: electricRate,
      );

      // 🚀 Send POST /api/v1/rooms to Go API / Supabase
      final result = await ApiService.createRoom({
        'roomNumber': roomNum,
        'floor': _selectedFloor,
        'roomType': _selectedRoomType,
        'baseRentPrice': price.toDouble(),
        'depositAmount': deposit,
        'waterRate': waterRate,
        'electricRate': electricRate,
        'water_rate': waterRate,
        'electric_rate': electricRate,
        'status': 'vacant',
        'dormId': 1,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        widget.onRoomAdded(newRoom);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มห้อง ${newRoom.roomNumber} เข้าสู่ระบบและบันทึกจริงเรียบร้อยแล้ว'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'ไม่สามารถบันทึกข้อมูลห้องได้';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // iOS Drag Handle
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

              // Title Row
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
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_home_work_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'เพิ่มห้องพักใหม่ (บันทึกจริง)',
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
                      // Room Number & Floor Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'เลขห้อง *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _roomNumberController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: 'เช่น 105, A201',
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
                                      return 'กรุณากรอกเลขห้อง';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ชั้นที่ *',
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
                                    child: DropdownButton<int>(
                                      value: _selectedFloor,
                                      isExpanded: true,
                                      icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                                      items: [1, 2, 3, 4, 5].map((floor) {
                                        return DropdownMenuItem<int>(
                                          value: floor,
                                          child: Text(
                                            'ชั้น $floor',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedFloor = val);
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

                      // Room Type Dropdown
                      const Text(
                        'ประเภทห้องพัก',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRoomType,
                            isExpanded: true,
                            icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                            items: _roomTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRoomType = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Monthly Price & Deposit
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
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
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
                                      return 'กรุณากรอกราคา';
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

                      // Water & Electric Rates (Auto-pulled from Settings)
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
                                  'อัตราค่าน้ำ - ค่าไฟของห้องนี้',
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
                                    'ดึงจากค่าตั้งต้นหอพัก',
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
                      const SizedBox(height: 16),

                      // Amenities Chips
                      const Text(
                        'สิ่งอำนวยความสะดวกในห้อง',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities.map((item) {
                          final isSelected = _selectedAmenities.contains(item);
                          return FilterChip(
                            label: Text(item),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add(item);
                                } else {
                                  _selectedAmenities.remove(item);
                                }
                              });
                            },
                            selectedColor: AppColors.primaryContainer,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                            backgroundColor: const Color(0xFFF2F2F7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(80)
                                    : Colors.transparent,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CupertinoActivityIndicator(color: Colors.white)
                              : const Text(
                                  'บันทึกและเพิ่มห้องพัก',
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
