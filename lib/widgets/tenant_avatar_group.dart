import 'package:flutter/material.dart';

/// Overlapping avatars widget or real tenants photo matching the Hero Card
class TenantAvatarGroup extends StatelessWidget {
  final double height;
  final String imagePath;

  const TenantAvatarGroup({
    super.key,
    this.height = 100,
    this.imagePath = 'assets/images/tenants_graphic.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height * 1.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildVectorFallback(),
    );
  }

  Widget _buildVectorFallback() {
    return SizedBox(
      height: height,
      width: 140,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Background back avatar 1
          Positioned(
            right: 80,
            bottom: 30,
            child: _buildAvatar(
              size: 44,
              bgColor: const Color(0xFFC78262),
              icon: Icons.person_rounded,
            ),
          ),
          // Background back avatar 2
          Positioned(
            right: 35,
            bottom: 35,
            child: _buildAvatar(
              size: 48,
              bgColor: const Color(0xFF536A7A),
              icon: Icons.person_rounded,
            ),
          ),
          // Background back avatar 3
          Positioned(
            right: 0,
            bottom: 30,
            child: _buildAvatar(
              size: 44,
              bgColor: const Color(0xFF8F6352),
              icon: Icons.person_rounded,
            ),
          ),
          // Foreground center-left avatar
          Positioned(
            right: 60,
            bottom: 0,
            child: _buildAvatar(
              size: 52,
              bgColor: const Color(0xFF4A6B82),
              icon: Icons.face_rounded,
              hasBorder: true,
            ),
          ),
          // Foreground center avatar
          Positioned(
            right: 20,
            bottom: 2,
            child: _buildAvatar(
              size: 56,
              bgColor: const Color(0xFFB55D3D),
              icon: Icons.face_retouching_natural_rounded,
              hasBorder: true,
            ),
          ),
          // Foreground right avatar
          Positioned(
            right: -6,
            bottom: 0,
            child: _buildAvatar(
              size: 48,
              bgColor: const Color(0xFF6B7280),
              icon: Icons.face_3_rounded,
              hasBorder: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required double size,
    required Color bgColor,
    required IconData icon,
    bool hasBorder = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(color: Colors.white, width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}
