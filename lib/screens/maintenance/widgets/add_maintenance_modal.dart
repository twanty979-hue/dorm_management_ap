import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/maintenance_item.dart';

/// Modal for adding a new maintenance ticket with live API sync
class AddMaintenanceModal extends StatefulWidget {
  final Function(MaintenanceItem) onAdd;

  const AddMaintenanceModal({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddMaintenanceModal> createState() => _AddMaintenanceModalState();
}

class _AddMaintenanceModalState extends State<AddMaintenanceModal> {
  final _roomController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _reporterNameController = TextEditingController();
  final _reporterPhoneController = TextEditingController();
  MaintenancePriority _priority = MaintenancePriority.normal;
  bool _isLoading = false;

  @override
  void dispose() {
    _roomController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    final room = _roomController.text.trim();
    final title = _titleController.text.trim();

    if (room.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาระบุเลขห้องและรายการแจ้งซ่อม'),
          backgroundColor: Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newItem = MaintenanceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomNumber: room,
      title: title,
      description: _descController.text.trim(),
      status: MaintenanceStatus.pending,
      priority: _priority,
      reportedAt: DateTime.now(),
      reporterName: _reporterNameController.text.trim().isEmpty
          ? 'ผู้ดูแลแจ้งแทน'
          : _reporterNameController.text.trim(),
      reporterPhone: _reporterPhoneController.text.trim().isEmpty
          ? '-'
          : _reporterPhoneController.text.trim(),
    );

    // 🚀 Send POST /api/v1/maintenance to Go API / Supabase
    String priorityStr = 'normal';
    if (_priority == MaintenancePriority.urgent) priorityStr = 'urgent';
    if (_priority == MaintenancePriority.low) priorityStr = 'low';

    await ApiService.createMaintenanceTicket({
      'roomId': int.tryParse(room) ?? 1,
      'roomNumber': room,
      'title': title,
      'description': _descController.text.trim(),
      'priority': priorityStr,
      'status': 'pending',
      'dormId': 1,
    });

    if (!mounted) return;
    setState(() => _isLoading = false);

    widget.onAdd(newItem);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เพิ่มรายการแจ้งซ่อมและบันทึกจริงสำเร็จ'),
        backgroundColor: Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grabber
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(40),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'แจ้งซ่อมใหม่ (บันทึกจริง)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.xmark, size: 16, color: Color(0xFF8E8E93)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Room Number
            const Text(
              'หมายเลขห้อง *',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                hintText: 'เช่น 101, 203',
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            const Text(
              'รายการ / อาการที่แจ้งซ่อม *',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'เช่น ก๊อกน้ำรั่ว, แอร์ไม่เย็น',
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Priority
            const Text(
              'ระดับความเร่งด่วน',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildPriorityOption(MaintenancePriority.urgent, 'ด่วนมาก', const Color(0xFFFF3B30)),
                const SizedBox(width: 8),
                _buildPriorityOption(MaintenancePriority.normal, 'ปกติ', AppColors.primary),
                const SizedBox(width: 8),
                _buildPriorityOption(MaintenancePriority.low, 'ไม่เร่งด่วน', const Color(0xFF8E8E93)),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'รายละเอียดเพิ่มเติม',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'รายละเอียดเพิ่มเติม เช่น จุดที่พบปัญหา...',
                filled: true,
                fillColor: const Color(0xFFF9F9FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reporter Name & Phone
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ชื่อผู้แจ้ง',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _reporterNameController,
                        decoration: InputDecoration(
                          hintText: 'ชื่อผู้เช่า/ผู้แจ้ง',
                          filled: true,
                          fillColor: const Color(0xFFF9F9FB),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เบอร์โทรศัพท์',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _reporterPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '08x-xxx-xxxx',
                          filled: true,
                          fillColor: const Color(0xFFF9F9FB),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withAlpha(15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text(
                        'เพิ่มรายการแจ้งซ่อม',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(MaintenancePriority priority, String label, Color color) {
    final isSelected = _priority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(25) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
