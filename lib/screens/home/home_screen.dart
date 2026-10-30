import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/home_header.dart';
import 'widgets/kbank_cashflow_card.dart';
import 'widgets/kbank_pending_section.dart';
import 'widgets/kbank_quick_actions.dart';

/// Banking & Cashflow Hub Dashboard (K PLUS Style) for Dormitory Owners
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110), // Bottom space for frosted tab bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              // 1. Top Header: Dorm Property Selector & Notifications
              HomeHeader(),
              SizedBox(height: 14),

              // 2. K PLUS Hero Cashflow Card (Monthly Revenue, Collected vs Unpaid)
              KBankCashflowCard(),
              SizedBox(height: 14),

              // 3. 4 Large Primary Action Buttons (Issue Bill, Read Meter, LINE Reminder, Repairs)
              KBankQuickActions(),
              SizedBox(height: 18),

              // 4. Actionable Overdue Rooms & Quick Room/Tenant Shortcuts
              KBankPendingSection(),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
