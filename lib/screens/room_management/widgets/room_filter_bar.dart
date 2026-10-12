import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Horizontal filter bar for quickly switching between room groups.
class RoomFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const RoomFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<String> filters = [
    'ทั้งหมด',
    'ชั้น 1',
    'ชั้น 2',
    'ชั้น 3',
    'ห้องว่าง',
    'มีผู้เช่า',
    'แจ้งซ่อม',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onFilterChanged(filter),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.black.withAlpha(10),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withAlpha(40)
                          : Colors.black.withAlpha(3),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconFor(filter),
                      size: 13,
                      color: isSelected ? Colors.white : AppColors.iconDefault,
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(String filter) {
    switch (filter) {
      case 'ทั้งหมด':
        return Icons.grid_view_rounded;
      case 'ชั้น 1':
      case 'ชั้น 2':
      case 'ชั้น 3':
        return Icons.layers_outlined;
      case 'ห้องว่าง':
        return Icons.door_front_door_outlined;
      case 'มีผู้เช่า':
        return Icons.person_outline_rounded;
      case 'แจ้งซ่อม':
        return Icons.handyman_outlined;
      default:
        return Icons.tune_rounded;
    }
  }
}
