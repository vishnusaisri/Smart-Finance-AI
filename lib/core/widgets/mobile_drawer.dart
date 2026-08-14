import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';

class MobileDrawer extends StatefulWidget {
  final String currentRoute;

  const MobileDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  State<MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<MobileDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<_DrawerItem> _items = [
    _DrawerItem(
      icon: Icons.dashboard_rounded,
      label: AppStrings.dashboard,
      route: '/dashboard',
    ),
    _DrawerItem(
      icon: Icons.account_balance_wallet_rounded,
      label: AppStrings.expenses,
      route: '/expenses',
    ),
    _DrawerItem(
      icon: Icons.account_balance_rounded,
      label: AppStrings.budgets,
      route: '/budgets',
    ),
    _DrawerItem(
      icon: Icons.analytics_rounded,
      label: AppStrings.analytics,
      route: '/analytics',
    ),
    _DrawerItem(
      icon: Icons.flash_on_rounded,
      label: AppStrings.impulseDetector,
      route: '/impulse',
    ),
    _DrawerItem(
      icon: Icons.trending_up_rounded,
      label: AppStrings.predictions,
      route: '/predictions',
    ),
    _DrawerItem(
      icon: Icons.auto_awesome_rounded,
      label: AppStrings.twinSimulator,
      route: '/twin-simulator',
    ),
    _DrawerItem(
      icon: Icons.smart_toy_rounded,
      label: AppStrings.aiAssistant,
      route: '/ai-assistant',
    ),
    _DrawerItem(
      icon: Icons.person_rounded,
      label: AppStrings.profile,
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Container(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: AppTextStyles.h6.copyWith(
                              color: iconColor,
                            ),
                          ),
                          Text(
                            'Smart Finance',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Divider(color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0)),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  children: _items
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildDrawerItem(item, index);
                      })
                      .toList(),
                ),
              ),

              Divider(color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0)),

              // Logout
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildDrawerItem(
                  const _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: AppStrings.logout,
                    route: '/auth/login',
                  ),
                  _items.length,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(begin: -0.3, end: 0, duration: 300.ms, curve: Curves.easeInOut);
  }

  Widget _buildDrawerItem(_DrawerItem item, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = widget.currentRoute == item.route ||
        (item.route != '/dashboard' &&
            widget.currentRoute.startsWith(item.route));

    final textColor = isActive ? AppColors.primary : (isDark ? Colors.white : const Color(0xFF0F172A));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            context.go(item.route);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? AppColors.primary.withOpacity(0.2)
                        : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isActive ? AppColors.primary : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: Duration(milliseconds: 50 * index),
    ).slideX(begin: -0.2, end: 0);
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
