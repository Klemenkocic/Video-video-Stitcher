import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;

  const FloatingNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (index == 0) context.go('/dashboard');
    if (index == 1) context.go('/videos');
    if (index == 2) context.go('/account');
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 220, // Wider for 3 items
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    isActive: currentIndex == 0,
                    onTap: () => _onTap(context, 0),
                  ),
                  _NavItem(
                    icon: Icons.play_circle_outline_rounded,
                    isActive: currentIndex == 1,
                    onTap: () => _onTap(context, 1),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    isActive: currentIndex == 2,
                    onTap: () => _onTap(context, 2),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: isActive
            ? const BoxDecoration(
                color: AppTheme.white, // White active indicator
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? AppTheme.black : AppTheme.greyMedium,
          size: 24,
        ),
      ),
    );
  }
}
