import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/room_item.dart';
import '../../invoice/create_invoice_screen.dart';
import '../../tenant_management/widgets/add_tenant_modal.dart';

/// Apple iOS Bottom Sheet modal showing full room details with live tenant sync
class RoomDetailModal extends StatefulWidget {
  final RoomItem room;

  const RoomDetailModal({
    super.key,
    required this.room,
  });

  static void show(BuildContext context, RoomItem room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomDetailModal(room: room),
    );
  }

  @override
  State<RoomDetailModal> createState() => _RoomDetailModalState();
}

class _RoomDetailModalState extends State<RoomDetailModal> {
  late String? _tenantName;
  late String? _tenantPhone;
  late String? _checkInDate;
  late RoomStatus _currentStatus;
  bool _isLoadingTenant = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.room.status;
    _tenantName = widget.room.tenantName;
    _tenantPhone = widget.room.tenantPhone;
    _checkInDate = widget.room.checkInDate;

    // Fallback: If room is occupied but tenantName is null or '-', query DB
    if (widget.room.isOccupied && (_tenantName == null || _tenantName == '-' || _tenantName!.isEmpty)) {
      _fetchTenantFromDb();
    }
  }

  void _fetchTenantFromDb() async {
    setState(() => _isLoadingTenant = true);
    final tenants = await ApiService.getTenants();
    if (!mounted) return;

    for (var t in tenants) {
      if (t['roomNumber']?.toString() == widget.room.roomNumber ||
          t['room_number']?.toString() == widget.room.roomNumber) {
        setState(() {
          _tenantName = t['fullName']?.toString() ?? t['full_name']?.toString() ?? 'ผู้เช่า';
          _tenantPhone = t['phone']?.toString() ?? '-';
          _checkInDate = t['startDate']?.toString() ?? t['start_date']?.toString() ?? '-';
          _isLoadingTenant = false;
        });
        return;
      }
    }

    setState(() => _isLoadingTenant = false);
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // iOS drag indicator handle
            Center(
              child: Container(
                width: 36,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header: Room Number + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ห้อง ${room.roomNumber}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ชั้น ${room.floor} • ${room.roomType}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (sheetContext) => CupertinoActionSheet(
                        title: Text('เปลี่ยนสถานะห้อง ${room.roomNumber}'),
                        message: const Text('เลือกสถานะห้องพักที่ต้องการอัปเดต'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              setState(() => _currentStatus = RoomStatus.vacant);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('เปลี่ยนสถานะเป็น: ห้องว่าง พร้อมเช่า'),
                                  backgroundColor: Color(0xFF34C759),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('🟢 ว่าง (พร้อมเช่า)'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              setState(() => _currentStatus = RoomStatus.occupied);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('เปลี่ยนสถานะเป็น: มีผู้เช่าแล้ว'),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('🟠 มีผู้เช่า'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              setState(() => _currentStatus = RoomStatus.maintenance);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('เปลี่ยนสถานะเป็น: ปิดปรับปรุง / แจ้งซ่อม'),
                                  backgroundColor: Color(0xFFFF9500),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('🟡 ปิดปรับปรุง / แจ้งซ่อม'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(_currentStatus.bgColorValue),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withAlpha(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStatus.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(_currentStatus.textColorValue),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.pencil,
                          size: 12,
                          color: Color(_currentStatus.textColorValue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withAlpha(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ค่าเช่ารายเดือน',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '฿${room.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / เดือน',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Rates (Water & Electricity)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF007AFF).withAlpha(30)),
              ),
              child: Builder(builder: (context) {
                final wRate = room.waterRate ?? 5.0;
                final eRate = room.electricRate ?? 10.0;
                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.drop_fill, color: Color(0xFF007AFF), size: 15),
                          const SizedBox(width: 6),
                          Text(
                            'ค่าน้ำ ฿${wRate.toStringAsFixed(wRate.truncateToDouble() == wRate ? 0 : 2)}/หน่วย',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 14, width: 1, color: Colors.black12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.bolt_fill, color: Color(0xFFFF9500), size: 15),
                          const SizedBox(width: 6),
                          Text(
                            'ค่าไฟ ฿${eRate.toStringAsFixed(eRate.truncateToDouble() == eRate ? 0 : 2)}/หน่วย',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),

            // Tenant Details (if occupied)
            if (room.isOccupied || room.isMaintenance) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ข้อมูลผู้เช่าปัจจุบัน',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_isLoadingTenant)
                    const CupertinoActivityIndicator(radius: 7),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withAlpha(10)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person_crop_circle_fill,
                            color: Color(0xFF8E8E93), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (_tenantName != null && _tenantName!.isNotEmpty) ? _tenantName! : 'ผู้เช่า',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.phone_fill,
                            color: Color(0xFF34C759), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (_tenantPhone != null && _tenantPhone!.isNotEmpty && _tenantPhone != '-')
                                ? _tenantPhone!
                                : '081-000-0000',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'โทรออก',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_checkInDate != null && _checkInDate!.isNotEmpty && _checkInDate != '-') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.calendar,
                              color: Color(0xFF007AFF), size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'เริ่มสัญญา: $_checkInDate',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Amenities List
            const Text(
              'สิ่งอำนวยความสะดวกในห้อง',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAmenityChip(CupertinoIcons.wind, 'เครื่องปรับอากาศ'),
                _buildAmenityChip(CupertinoIcons.bed_double, 'เตียง 5 ฟุต'),
                _buildAmenityChip(CupertinoIcons.wifi, 'อินเทอร์เน็ต WiFi'),
                _buildAmenityChip(CupertinoIcons.sparkles, 'เครื่องทำน้ำอุ่น'),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: Colors.black.withAlpha(20)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'ปิด',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (room.isVacant) {
                        AddTenantModal.show(context, onTenantAdded: (_) {});
                      } else {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const CreateInvoiceScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      room.isVacant ? 'ทำสัญญาเช่าใหม่' : 'ออกใบแจ้งหนี้',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
