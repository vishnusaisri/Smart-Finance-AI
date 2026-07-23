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
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
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
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Smart Finance',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0x1AFFFFFF)),

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

              const Divider(color: Color(0x1AFFFFFF)),

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
    final isActive = widget.currentRoute == item.route ||
        (item.route != '/dashboard' &&
            widget.currentRoute.startsWith(item.route));

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
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isActive ? AppColors.primary : Colors.white,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
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
