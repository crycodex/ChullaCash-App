import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 16,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: isDark ? 0 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, context),
            _buildNavItem(1, Icons.bar_chart_rounded, context),
            _buildNavItem(2, Icons.add_circle_outline_rounded, context),
            _buildNavItem(3, Icons.account_balance_wallet_rounded, context),
            _buildNavItem(4, Icons.person_rounded, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, BuildContext context) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryGreen
                  : isDark
                      ? AppColors.textLight.withOpacity(0.6)
                      : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
