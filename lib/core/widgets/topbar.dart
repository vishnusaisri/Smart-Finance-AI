import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../routes/app_routes.dart';

class TopBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSearch;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;

  const TopBar({
    super.key,
    required this.title,
    this.actions,
    this.showSearch = true,
    this.showMenuButton = false,
    this.onMenuPressed,
    this.onProfilePressed,
  });

  @override
  ConsumerState<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _TopBarState extends ConsumerState<TopBar> {
  int _unreadNotificationsCount = 3;

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Notifications', style: AppTextStyles.h3),
                        ],
                      ),
                      if (_unreadNotificationsCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _unreadNotificationsCount = 0;
                            });
                            setModalState(() {});
                          },
                          child: const Text('Mark all as read', style: TextStyle(color: AppColors.primary)),
                        ),
                    ],
                  ),
                  const Divider(color: Color(0x1AFFFFFF)),
                  const SizedBox(height: AppSpacing.sm),
                  _buildNotificationTile(
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.warning,
                    title: 'Budget Alert',
                    subtitle: 'Food & Dining is close to your monthly limit (82% spent).',
                    time: '10m ago',
                  ),
                  _buildNotificationTile(
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    title: 'Smart AI Insight',
                    subtitle: 'New savings recommendation available on your dashboard.',
                    time: '1h ago',
                  ),
                  _buildNotificationTile(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    title: 'Monthly Summary Ready',
                    subtitle: 'Your financial health report for this month is generated.',
                    time: '1d ago',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyles.labelLarge),
                      Text(time, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final userProfile = ref.watch(userProfileProvider);
    final userInitial = userProfile.fullName.isNotEmpty ? userProfile.fullName[0].toUpperCase() : 'U';

    return SafeArea(
      bottom: false,
      child: Container(
        height: widget.preferredSize.height,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.showMenuButton)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: widget.onMenuPressed,
              padding: EdgeInsets.zero,
            ),
          if (widget.showMenuButton) const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              widget.title,
              style: AppTextStyles.h4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (!isMobile && widget.showSearch)
            Container(
              width: isTablet ? 200 : 300,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                  ),
                ),
              ),
            ),
          if (!isMobile && widget.showSearch) const SizedBox(width: AppSpacing.lg),

          // Notification Bell with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                tooltip: 'Notifications',
                onPressed: () => _showNotificationsModal(context),
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // Interactive Profile Avatar
          Tooltip(
            message: 'View Profile',
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (widget.onProfilePressed != null) {
                  widget.onProfilePressed!();
                } else {
                  context.go(RouteNames.profile);
                }
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.actions != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ...widget.actions!,
          ],
        ],
      ),
    ),
  );
}
}
