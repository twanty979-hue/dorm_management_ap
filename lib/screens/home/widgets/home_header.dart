import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/dorm_property_item.dart';
import '../../../widgets/hex_logo.dart';
import '../../../widgets/property_switcher_modal.dart';
import 'notification_center_modal.dart';

/// Top bar header for Home Screen with Property Switcher & Notification Bell
class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  DormPropertyItem _currentProperty = DormPropertyItem.sampleProperties[0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Property Selector Dropdown (Wrapped in Expanded to prevent right overflow)
        Expanded(
          child: GestureDetector(
            onTap: () {
              PropertySwitcherModal.show(
                context,
                currentProperty: _currentProperty,
                onPropertySelected: (newProp) {
                  setState(() => _currentProperty = newProp);
                },
              );
            },
            child: Row(
              children: [
                const HexLogo(size: 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _currentProperty.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 13,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34C759),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${_currentProperty.totalRooms} ห้อง • ว่าง ${_currentProperty.vacantRooms} ห้อง',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF34C759),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Right Side: Billing Cycle Badge & Notification Bell
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'ต.ค. 2026',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Notification Bell Button
            GestureDetector(
              onTap: () {
                NotificationCenterModal.show(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.bell,
                      color: AppColors.textPrimary,
                      size: 19,
                    ),
                    Positioned(
                      top: 9,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
