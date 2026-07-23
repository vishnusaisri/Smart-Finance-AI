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

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCollapsed ? 80 : 270,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(
              right: BorderSide(
                color: Color(0x1AFFFFFF),
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
    final isActive = widget.currentRoute == item.route ||
        (item.route != '/dashboard' &&
            widget.currentRoute.startsWith(item.route));

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
                color: isActive
                    ? const Color(0xFF8B5CF6).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: isActive
                    ? const Color(0xFF8B5CF6)
                    : Colors.white70,
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
          tileColor: isActive
              ? const Color(0xFF8B5CF6).withOpacity(0.15)
              : Colors.transparent,
          leading: Icon(
            item.icon,
            color: isActive
                ? const Color(0xFF8B5CF6)
                : Colors.white70,
          ),
          title: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white70,
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
