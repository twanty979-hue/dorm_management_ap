import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/create_invoice_banner.dart';
import 'widgets/home_bento_stats.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero_carousel.dart';
import 'widgets/home_menu_grid.dart';
import 'widgets/home_story_bar.dart';
import 'widgets/maintenance_list_section.dart';

/// Screen 1: Main Home & Dashboard Screen with Full-width Auto-sliding Hero Carousel & Story Status
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110), // Bottom padding for frosted bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              // Top Bar: Property Switcher & Notification Bell
              HomeHeader(),
              SizedBox(height: 14),

              // Instagram Stories Ring Bar (สถานะด่วน: ห้องว่าง, แจ้งซ่อมด่วน, บิลค้างชำระ)
              HomeStoryBar(),
              SizedBox(height: 16),

              // Full-width Auto-sliding Hero Carousel (ข่าวสาร & ประกาศหอพัก)
              HomeHeroCarousel(),
              SizedBox(height: 18),

              // Modern Bento Stats Grid (สถิติรวม)
              HomeBentoStats(),
              SizedBox(height: 18),

              // Quick Action Gradient Banner (สร้างใบแจ้งหนี้ใหม่ด่วน)
              CreateInvoiceBanner(),
              SizedBox(height: 20),

              // 6 Main Action Menus Grid
              HomeMenuGrid(),
              SizedBox(height: 22),

              // Pending Maintenance Requests List
              MaintenanceListSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
