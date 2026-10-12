import 'package:flutter/material.dart';

/// Apple iOS Design Guidelines styling constants
class AppStyles {
  AppStyles._();

  // iOS Squircles & Radii
  static const double cardRadius = 20.0;
  static const double largeRadius = 24.0;
  static const double buttonRadius = 16.0;
  static const double pillRadius = 30.0;
  static const double chipRadius = 10.0;

  // iOS Subtle Diffused Shadows
  static List<BoxShadow> get iosCardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(8), // ~0.03
          blurRadius: 14,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get iosElevatedShadow => [
        BoxShadow(
          color: const Color(0xFFC45A34).withAlpha(45),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get iosFloatingShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
