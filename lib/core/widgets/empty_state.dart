import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.accent.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(duration: 600.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Title
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: AppSpacing.md),
            
            // Description
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: AppSpacing.xl),
            
            // Action Button
            if (actionText != null && onActionPressed != null)
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(
                begin: 0.2,
                end: 0,
              ),
          ],
        ),
      ),
    );
  }
}

// Predefined empty states
class EmptyStates {
  static Widget expenses({VoidCallback? onAddPressed}) {
    return EmptyState(
      icon: Icons.receipt_long_rounded,
      title: 'No Expenses Yet',
      description: 'Start tracking your expenses by adding your first transaction.',
      actionText: 'Add Expense',
      onActionPressed: onAddPressed,
    );
  }

  static Widget budget({VoidCallback? onCreatePressed}) {
    return EmptyState(
      icon: Icons.account_balance_wallet_rounded,
      title: 'No Budgets Set',
      description: 'Create a budget to start tracking your spending limits.',
      actionText: 'Create Budget',
      onActionPressed: onCreatePressed,
    );
  }

  static Widget analytics({VoidCallback? onRefreshPressed}) {
    return EmptyState(
      icon: Icons.analytics_rounded,
      title: 'No Analytics Data',
      description: 'Add some expenses to see your spending analytics.',
      actionText: 'Refresh',
      onActionPressed: onRefreshPressed,
    );
  }

  static Widget search({String? query}) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      description: query != null && query.isNotEmpty
          ? 'No expenses match "$query"'
          : 'Try searching for something else.',
    );
  }

  static Widget impulse({VoidCallback? onTrackPressed}) {
    return EmptyState(
      icon: Icons.flash_on_rounded,
      title: 'No Impulse Data',
      description: 'Track your impulse purchases to get insights.',
      actionText: 'Start Tracking',
      onActionPressed: onTrackPressed,
    );
  }

  static Widget predictions({VoidCallback? onRefreshPressed}) {
    return EmptyState(
      icon: Icons.trending_up_rounded,
      title: 'No Predictions Available',
      description: 'Add more expense data to generate financial predictions.',
      actionText: 'Refresh',
      onActionPressed: onRefreshPressed,
    );
  }

  static Widget notifications() {
    return EmptyState(
      icon: Icons.notifications_none_rounded,
      title: 'No Notifications',
      description: 'You\'re all caught up! Check back later for updates.',
    );
  }

  static Widget goals({VoidCallback? onCreatePressed}) {
    return EmptyState(
      icon: Icons.flag_rounded,
      title: 'No Financial Goals',
      description: 'Set financial goals to track your progress.',
      actionText: 'Create Goal',
      onActionPressed: onCreatePressed,
    );
  }

  static Widget error({String? message, VoidCallback? onRetryPressed}) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Something Went Wrong',
      description: message ?? 'An error occurred. Please try again.',
      actionText: 'Retry',
      onActionPressed: onRetryPressed,
    );
  }

  static Widget network({VoidCallback? onRetryPressed}) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'No Connection',
      description: 'Check your internet connection and try again.',
      actionText: 'Retry',
      onActionPressed: onRetryPressed,
    );
  }
}
