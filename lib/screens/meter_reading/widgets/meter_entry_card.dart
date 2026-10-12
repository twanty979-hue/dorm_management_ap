import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/meter_item.dart';

/// Card for recording electricity and water meters for a room with live units and cost calculation
class MeterEntryCard extends StatefulWidget {
  final MeterItem item;
  final Function(double currentElec, double currentWater) onSave;

  const MeterEntryCard({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<MeterEntryCard> createState() => _MeterEntryCardState();
}

class _MeterEntryCardState extends State<MeterEntryCard> {
  late TextEditingController _electricController;
  late TextEditingController _waterController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.item.isRecorded;
    _electricController = TextEditingController(
      text: widget.item.currentElectric != null ? widget.item.currentElectric!.toStringAsFixed(0) : '',
    );
    _waterController = TextEditingController(
      text: widget.item.currentWater != null ? widget.item.currentWater!.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant MeterEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _isSaved = widget.item.isRecorded;
    }
  }

  @override
  void dispose() {
    _electricController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  double get _currentElectric => double.tryParse(_electricController.text) ?? widget.item.prevElectric;
  double get _currentWater => double.tryParse(_waterController.text) ?? widget.item.prevWater;

  double get _elecUnits => (_currentElectric >= widget.item.prevElectric) ? (_currentElectric - widget.item.prevElectric) : 0.0;
  double get _waterUnits => (_currentWater >= widget.item.prevWater) ? (_currentWater - widget.item.prevWater) : 0.0;

  double get _elecCost => _elecUnits * widget.item.electricRate;
  double get _waterCost => _waterUnits * widget.item.waterRate;

  void _saveThisRoom() {
    final curElec = double.tryParse(_electricController.text) ?? widget.item.prevElectric;
    final curWater = double.tryParse(_waterController.text) ?? widget.item.prevWater;

    setState(() => _isSaved = true);
    widget.onSave(curElec, curWater);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกมิเตอร์ห้อง ${widget.item.roomNumber} (ใช้ไฟ ${_elecUnits.toInt()} น. / น้ำ ${_waterUnits.toInt()} น.) สำเร็จ ✅'),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSaved ? const Color(0xFF34C759).withAlpha(120) : Colors.black.withAlpha(8),
          width: _isSaved ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Room & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ห้อง ${widget.item.roomNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.tenantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.item.isOccupied ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isSaved ? const Color(0xFFE8F9EE) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isSaved ? '✓ จดแล้ว' : 'ยังไม่จด',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _isSaved ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Electricity Meter Row
            _buildMeterRow(
              icon: CupertinoIcons.bolt_fill,
              iconColor: const Color(0xFFD47C38),
              title: 'มิเตอร์ไฟ (${widget.item.electricRate.toStringAsFixed(0)}฿/หน่วย)',
              prevValue: widget.item.prevElectric.toStringAsFixed(0),
              controller: _electricController,
              unitsUsed: _elecUnits,
              cost: _elecCost,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Water Meter Row
            _buildMeterRow(
              icon: CupertinoIcons.drop_fill,
              iconColor: const Color(0xFF007AFF),
              title: 'มิเตอร์น้ำ (${widget.item.waterRate.toStringAsFixed(0)}฿/หน่วย)',
              prevValue: widget.item.prevWater.toStringAsFixed(0),
              controller: _waterController,
              unitsUsed: _waterUnits,
              cost: _waterCost,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Total utility cost preview pill (when units > 0)
            if (_elecUnits > 0 || _waterUnits > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'รวมค่าน้ำ + ค่าไฟเดือนนี้:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      Text(
                        '฿${(_elecCost + _waterCost).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),

            // Save Action
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: _saveThisRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved ? const Color(0xFFE8F9EE) : AppColors.primary,
                  foregroundColor: _isSaved ? const Color(0xFF2E7D32) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSaved ? '✓ บันทึกมิเตอร์แล้ว' : 'บันทึกมิเตอร์ห้องนี้',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeterRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String prevValue,
    required TextEditingController controller,
    required double unitsUsed,
    required double cost,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'เลขเดิม: $prevValue',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (unitsUsed > 0) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '(ใช้ ${unitsUsed.toInt()} น. = ฿${cost.toInt()})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            height: 34,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'เลขใหม่',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
