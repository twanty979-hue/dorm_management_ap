import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/hex_logo.dart';

/// Header for Login screen showing logo, title, and welcome text
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const HexLogo(size: 68),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withAlpha(50), width: 0.8),
          ),
          child: const Text(
            'MULTI-PROPERTY SAAS PLATFORM',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ระบบจัดการหอพัก SaaS',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'ระบบคลาวด์สำหรับเจ้าของหอพักและฝ่ายบริหาร',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
