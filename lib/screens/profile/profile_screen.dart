import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'widgets/edit_profile_modal.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/property_info_card.dart';

/// Full Apple iOS styled Profile Screen (หน้าโปรไฟล์ผู้ดูแล)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'คุณณภัทร วุฒิเดช';
  final String _role = 'เจ้าของหอพัก';
  String _email = 'owner@greendorm.app';
  String _phone = '089-123-4567';

  void _openEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(
        currentName: _name,
        currentEmail: _email,
        currentPhone: _phone,
        onSave: (newName, newEmail, newPhone) {
          setState(() {
            _name = newName;
            _email = newEmail;
            _phone = newPhone;
          });
        },
      ),
    );
  }

  void _onLogout() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบจัดการหอพักใช่หรือไม่?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('ออกจากระบบ'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 14),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withAlpha(8)),
                    ),
                    child: const Icon(
                      CupertinoIcons.chevron_back,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              )
            : null,
        title: const Text(
          'โปรไฟล์ผู้ดูแล',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: _openEditModal,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(120),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.pencil,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Colors.black.withAlpha(12),
            height: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Profile Header Card
            ProfileHeaderCard(
              name: _name,
              role: _role,
              email: _email,
              phone: _phone,
              onEditTap: _openEditModal,
            ),
            const SizedBox(height: 14),

            // Property Info Card
            const PropertyInfoCard(),
            const SizedBox(height: 16),

            // Section 1: Team & Permissions (Apple Grouped List)
            _buildSectionHeader('การจัดการทีมงานและความปลอดภัย'),
            const SizedBox(height: 8),
            _buildGroupedCard([
              _buildMenuItem(
                icon: CupertinoIcons.person_2_fill,
                iconColor: const Color(0xFF007AFF),
                title: 'จัดการทีมงานและสิทธิ์ (Staff)',
                subtitle: 'ผู้ดูแล 2 คน • ช่างประจำ 3 คน',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เปิดหน้าจัดการทีมงานและสิทธิ์'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: CupertinoIcons.lock_shield_fill,
                iconColor: const Color(0xFF34C759),
                title: 'ความปลอดภัยและรหัสผ่าน',
                subtitle: 'เปลี่ยนรหัสผ่าน • Touch ID / Face ID',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เปิดหน้าตั้งค่าความปลอดภัย'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: CupertinoIcons.qrcode_viewfinder,
                iconColor: const Color(0xFFFF9500),
                title: 'บัญชีธนาคารและ QR พร้อมเพย์',
                subtitle: 'กสิกรไทย 098-2-34567-8',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เปิดหน้าจัดการบัญชีรับเงิน'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                isLast: true,
              ),
            ]),
            const SizedBox(height: 16),

            // Section 2: Support & App Info
            _buildSectionHeader('ความช่วยเหลือและข้อมูลระบบ'),
            const SizedBox(height: 8),
            _buildGroupedCard([
              _buildMenuItem(
                icon: CupertinoIcons.question_circle_fill,
                iconColor: const Color(0xFF5856D6),
                title: 'คู่มือการใช้งานระบบหอพัก',
                subtitle: 'วิธีออกบิล จดมิเตอร์ และผูก LINE OA',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เปิดคู่มือการใช้งานระบบ'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: CupertinoIcons.chat_bubble_2_fill,
                iconColor: const Color(0xFF06C755),
                title: 'ติดต่อฝ่ายสนับสนุนลูกค้า',
                subtitle: 'LINE: @dorm_support (09:00 - 18:00)',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กำลังเปิดช่องทางติดต่อฝ่ายสนับสนุน...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: CupertinoIcons.info_circle_fill,
                iconColor: AppColors.iconDefault,
                title: 'เกี่ยวกับแอปพลิเคชัน',
                subtitle: 'Dorm Management Pro v1.0.0 (Build 2026)',
                onTap: () {},
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),

            // Logout Button (Apple Red Button)
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _onLogout,
                icon: const Icon(CupertinoIcons.square_arrow_right, color: Color(0xFFFF3B30), size: 18),
                label: const Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF3B30),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  side: BorderSide(color: const Color(0xFFFF3B30).withAlpha(50), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            highlightColor: Colors.black.withAlpha(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    size: 15,
                    color: AppColors.chevron,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 64, thickness: 0.5),
      ],
    );
  }
}
