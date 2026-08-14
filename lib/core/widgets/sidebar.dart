import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';

class Sidebar extends StatefulWidget {
  final String currentRoute;

  const Sidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isCollapsed = false;

  final List<_SidebarItem> _items = [
    _SidebarItem(
      icon: Icons.dashboard_rounded,
      label: AppStrings.dashboard,
      route: '/dashboard',
    ),
    _SidebarItem(
      icon: Icons.account_balance_wallet_rounded,
      label: AppStrings.expenses,
      route: '/expenses',
    ),
    _SidebarItem(
      icon: Icons.account_balance_rounded,
      label: AppStrings.budgets,
      route: '/budgets',
    ),
    _SidebarItem(
      icon: Icons.analytics_rounded,
      label: AppStrings.analytics,
      route: '/analytics',
    ),
    _SidebarItem(
      icon: Icons.flash_on_rounded,
      label: AppStrings.impulseDetector,
      route: '/impulse',
    ),
    _SidebarItem(
      icon: Icons.trending_up_rounded,
      label: AppStrings.predictions,
      route: '/predictions',
    ),
    _SidebarItem(
      icon: Icons.auto_awesome_rounded,
      label: AppStrings.twinSimulator,
      route: '/twin-simulator',
    ),
    _SidebarItem(
      icon: Icons.smart_toy_rounded,
      label: AppStrings.aiAssistant,
      route: '/ai-assistant',
    ),
    _SidebarItem(
      icon: Icons.person_rounded,
      label: AppStrings.profile,
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;
        
        // Auto-collapse on smaller screens/tablets
        final shouldCollapse = isTablet || constraints.maxHeight < 900;
        final isCollapsed = _isCollapsed || shouldCollapse;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCollapsed ? 80 : 270,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Logo/Header
              Container(
                height: 72,
                padding: EdgeInsets.symmetric(horizontal: isCollapsed ? AppSpacing.md : AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.h6,
                      ),
                    ],
                    if (!shouldCollapse) ...[
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isCollapsed
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  children: _items
                      .map((item) => _buildSidebarItem(item, isCollapsed))
                      .toList(),
                ),
              ),

              const Divider(),

              // Logout
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: _buildSidebarItem(
                  const _SidebarItem(
                    icon: Icons.logout_rounded,
                    label: AppStrings.logout,
                    route: '/auth/login',
                  ),
                  isCollapsed,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
      },
    );
  }

  Widget _buildSidebarItem(_SidebarItem item, bool isCollapsed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = widget.currentRoute == item.route ||
        (item.route != '/dashboard' &&
            widget.currentRoute.startsWith(item.route));

    final activeBg = const Color(0xFF8B5CF6).withOpacity(isDark ? 0.15 : 0.12);
    final activeColor = const Color(0xFF8B5CF6);
    final inactiveColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final activeTextColor = isDark ? Colors.white : const Color(0xFF8B5CF6);

    // COLLAPSED MODE
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              context.go(item.route);
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
        ),
      );
    }

    // EXPANDED MODE
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tileColor: isActive ? activeBg : Colors.transparent,
          leading: Icon(
            item.icon,
            color: isActive ? activeColor : inactiveColor,
          ),
          title: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? activeTextColor : inactiveColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: () {
            context.go(item.route);
          },
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
