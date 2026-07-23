import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSearch;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const TopBar({
    super.key,
    required this.title,
    this.actions,
    this.showSearch = true,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      height: preferredSize.height,
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
          if (showMenuButton)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed,
              padding: EdgeInsets.zero,
            ),
          if (showMenuButton) const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.h4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (!isMobile && showSearch)
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
          if (!isMobile && showSearch) const SizedBox(width: AppSpacing.lg),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
          if (actions != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ...actions!,
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
