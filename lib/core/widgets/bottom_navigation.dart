import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BottomNavigation extends StatelessWidget {
  final String currentRoute;

  const BottomNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Home',
                route: '/dashboard',
                isActive: currentRoute == '/dashboard',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Expenses',
                route: '/expenses',
                isActive: currentRoute.startsWith('/expenses'),
                context: context,
              ),
              _buildNavItem(
                icon: Icons.account_balance_rounded,
                label: 'Budgets',
                route: '/budgets',
                isActive: currentRoute == '/budgets',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.analytics_rounded,
                label: 'Analytics',
                route: '/analytics',
                isActive: currentRoute == '/analytics',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                route: '/profile',
                isActive: currentRoute == '/profile',
                context: context,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
    required BuildContext context,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? AppColors.primary : Colors.grey.shade400,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
