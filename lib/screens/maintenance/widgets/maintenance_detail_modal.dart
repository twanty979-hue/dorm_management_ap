import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/maintenance_item.dart';

/// Apple iOS bottom sheet for viewing and updating maintenance ticket details
class MaintenanceDetailModal extends StatefulWidget {
  final MaintenanceItem item;
  final Function(MaintenanceItem) onUpdate;

  const MaintenanceDetailModal({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<MaintenanceDetailModal> createState() => _MaintenanceDetailModalState();
}

class _MaintenanceDetailModalState extends State<MaintenanceDetailModal> {
  late MaintenanceStatus _status;
  late TextEditingController _techController;
  late TextEditingController _costController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _techController = TextEditingController(text: widget.item.technicianName ?? '');
    _costController = TextEditingController(
        text: widget.item.estimatedCost != null
            ? widget.item.estimatedCost!.toStringAsFixed(0)
            : '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _techController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final cost = double.tryParse(_costController.text.trim());
    final updated = widget.item.copyWith(
      status: _status,
      technicianName: _techController.text.trim().isEmpty ? null : _techController.text.trim(),
      estimatedCost: cost,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    widget.onUpdate(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการเปลี่ยนแปลงเรียบร้อยแล้ว'),
        backgroundColor: Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
            // Grabber Handle
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ห้อง ${item.roomNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.priority == MaintenancePriority.urgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ด่วนมาก',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF3B30),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.xmark, size: 16, color: Color(0xFF8E8E93)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Problem Description Box
            if (item.description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withAlpha(6)),
                ),
                child: Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
            const SizedBox(height: 14),

            // Reporter & Time Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withAlpha(10), width: 0.8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(CupertinoIcons.person_fill, 'ผู้แจ้ง', item.reporterName),
                  const Divider(height: 14, thickness: 0.5),
                  _buildInfoRow(CupertinoIcons.phone_fill, 'เบอร์โทร', item.reporterPhone),
                  const Divider(height: 14, thickness: 0.5),
                  _buildInfoRow(
                    CupertinoIcons.clock_fill,
                    'เวลาที่แจ้ง',
                    '${item.reportedAt.day}/${item.reportedAt.month}/${item.reportedAt.year} เวลา ${item.reportedAt.hour.toString().padLeft(2, '0')}:${item.reportedAt.minute.toString().padLeft(2, '0')} น.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Selector
            const Text(
              'ปรับสถานะงาน',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusOption(MaintenanceStatus.pending, 'รอดำเนินการ', AppColors.primary),
                const SizedBox(width: 8),
                _buildStatusOption(MaintenanceStatus.inProgress, 'กำลังทำ', const Color(0xFF007AFF)),
                const SizedBox(width: 8),
                _buildStatusOption(MaintenanceStatus.completed, 'เสร็จสิ้น', const Color(0xFF34C759)),
              ],
            ),
            const SizedBox(height: 16),

            // Technician Name Input
            const Text(
              'ช่างผู้รับผิดชอบ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _techController,
              decoration: InputDecoration(
                hintText: 'ระบุชื่อช่าง...',
                prefixIcon: const Icon(CupertinoIcons.wrench, size: 18, color: AppColors.iconDefault),
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
            const SizedBox(height: 14),

            // Cost & Notes
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ค่าใช้จ่าย (บาท)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: const Icon(CupertinoIcons.money_dollar, size: 18, color: AppColors.iconDefault),
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
            const SizedBox(height: 14),

            // Notes Input
            const Text(
              'หมายเหตุ / รายละเอียดการแก้ไข',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'ระบุรายละเอียดผลการซ่อม อะไหล่ที่เปลี่ยน...',
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
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'บันทึกข้อมูล',
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

  Widget _buildStatusOption(MaintenanceStatus status, String label, Color color) {
    final isSelected = _status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.iconDefault),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
