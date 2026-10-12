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
        const SizedBox(height: 18),
        const Text(
          'ระบบจัดการหอพัก',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'เข้าสู่ระบบสำหรับเจ้าของหอพักและผู้ดูแล',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
