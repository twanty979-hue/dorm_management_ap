import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../financial_report/financial_report_screen.dart';
import '../../invoice/create_invoice_screen.dart';
import '../../line_oa/line_oa_screen.dart';
import '../../meter_reading/meter_reading_screen.dart';

/// Full-width auto-sliding modern Hero Banner Carousel with smooth animations
class HomeHeroCarousel extends StatefulWidget {
  const HomeHeroCarousel({super.key});

  @override
  State<HomeHeroCarousel> createState() => _HomeHeroCarouselState();
}

class _HomeHeroCarouselState extends State<HomeHeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<_HeroSlideData> _slides = [
    const _HeroSlideData(
      badge: '✨ ระบบจัดการหอพัก AI',
      title: 'ยินดีต้อนรับ, คุณณภัทร',
      subtitle: 'The Green Residence • พร้อมเพย์ & LINE OA ทำงานปกติ',
      buttonText: 'สร้างใบแจ้งหนี้ใหม่',
      icon: CupertinoIcons.paperplane_fill,
      gradientColors: [Color(0xFFC45A34), Color(0xFFE87A50)],
      actionType: _SlideAction.createInvoice,
    ),
    const _HeroSlideData(
      badge: '⚡ รอบบิล ส.ค. 2026',
      title: 'จดมิเตอร์แล้ว 45 / 50 ห้อง',
      subtitle: 'เหลืออีกเพียง 5 ห้อง เพื่อออกบิลประจำเดือนครบถ้วน',
      buttonText: 'บันทึกมิเตอร์ต่อ',
      icon: CupertinoIcons.bolt_fill,
      gradientColors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
      actionType: _SlideAction.meterReading,
    ),
    const _HeroSlideData(
      badge: '💰 สรุปรายรับเดือนนี้',
      title: 'ยอดรวม ฿248,500',
      subtitle: 'อัตราการเข้าพัก 90% (ว่าง 5 ห้อง) • เก็บได้แล้ว 94%',
      buttonText: 'ดูรายงานการเงิน',
      icon: CupertinoIcons.chart_bar_square_fill,
      gradientColors: [Color(0xFF134E5E), Color(0xFF3B8D76)],
      actionType: _SlideAction.financialReport,
    ),
    const _HeroSlideData(
      badge: '💬 LINE Official Account',
      title: 'ผูกบัญชีผู้เช่า 45 คน',
      subtitle: 'พร้อมส่ง Flex Message แจ้งเตือนบิลและใบเสร็จอัตโนมัติ',
      buttonText: 'ส่งประกาศ Broadcast',
      icon: CupertinoIcons.chat_bubble_2_fill,
      gradientColors: [Color(0xFF06C755), Color(0xFF007E33)],
      actionType: _SlideAction.lineOa,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleSlideTap(_SlideAction action) {
    switch (action) {
      case _SlideAction.createInvoice:
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const CreateInvoiceScreen()),
        );
        break;
      case _SlideAction.meterReading:
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const MeterReadingScreen()),
        );
        break;
      case _SlideAction.financialReport:
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const FinancialReportScreen()),
        );
        break;
      case _SlideAction.lineOa:
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const LineOaScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Full Width Sliding Hero Banner
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _buildSlideCard(slide);
            },
          ),
        ),
        const SizedBox(height: 10),

        // Animated Pill Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isSelected = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              height: 5,
              width: isSelected ? 22 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? _slides[_currentPage].gradientColors.first
                    : const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSlideCard(_HeroSlideData slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: slide.gradientColors.first.withAlpha(70),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Ambient Aesthetic Shapes
            Positioned(
              right: -20,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(22),
                ),
              ),
            ),
            Positioned(
              right: 40,
              top: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(15),
                ),
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Badge & Glass Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(60),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          slide.badge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            slide.icon,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle: Title & Subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        slide.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF6F6F9),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Action Button
                  GestureDetector(
                    onTap: () => _handleSlideTap(slide.actionType),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.buttonText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: slide.gradientColors.first,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 12,
                            color: slide.gradientColors.first,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SlideAction {
  createInvoice,
  meterReading,
  financialReport,
  lineOa,
}

class _HeroSlideData {
  final String badge;
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final List<Color> gradientColors;
  final _SlideAction actionType;

  const _HeroSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.gradientColors,
    required this.actionType,
  });
}
