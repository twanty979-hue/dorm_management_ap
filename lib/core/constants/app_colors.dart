import 'package:flutter/material.dart';

/// Apple / iOS-inspired color palette for the dormitory management app
class AppColors {
  AppColors._();

  // Primary Terracotta / Apple Warm Rust
  static const Color primary = Color(0xFFC45A34);
  static const Color primaryLight = Color(0xFFE2724D);
  static const Color primaryDark = Color(0xFFA34524);
  static const Color primaryContainer = Color(0xFFFBECE5);

  // iOS System Backgrounds
  static const Color background = Color(0xFFF2F2F7); // iOS System Grouped Background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0x0F000000); // 6% black subtle separator

  // iOS System Typography
  static const Color textPrimary = Color(0xFF1C1C1E); // iOS System Label
  static const Color textSecondary = Color(0xFF8E8E93); // iOS Secondary Label
  static const Color textMuted = Color(0xFFAEC6CF);
  static const Color textTertiary = Color(0xFFC7C7CC);

  // Badges & Status
  static const Color statusPendingBg = Color(0xFFC45A34);
  static const Color statusPendingText = Color(0xFFFFFFFF);
  static const Color statusDoneBg = Color(0xFFE5E5EA); // iOS System Gray 5
  static const Color statusDoneText = Color(0xFF8E8E93);

  // Decorative Cards & Gradients
  static const Color heroCardBg = Color(0xFFFBF1EB);
  static const Color premiumBannerBg = Color(0xFFFCF4EE);
  static const Color premiumBorder = Color(0xFFF5DACB);
  static const Color crownGold = Color(0xFFD97736);

  // Frosted Glass
  static const Color glassWhite = Color(0xDDFFFFFF);
  static const Color chevron = Color(0xFFC7C7CC); // iOS Chevron color
  static const Color iconDefault = Color(0xFF636366);
}
