import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

/// Screen for authenticating the dormitory owner
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginHeader(),
                  SizedBox(height: 28),
                  LoginForm(),
                  SizedBox(height: 24),
                  Text(
                    'เวอร์ชัน 1.0.0 (Demo Mode)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
