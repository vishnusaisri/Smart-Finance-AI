import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_strings.dart';

class SavingsGoalsCard extends StatelessWidget {
  final List<FinancialGoal> goals;

  const SavingsGoalsCard({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.savingsGoals,
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...goals.take(3).map((goal) => _GoalProgressCard(goal: goal)),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final FinancialGoal goal;

  const _GoalProgressCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress / 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.name,
                style: AppTextStyles.labelLarge,
              ),
              Text(
                '${goal.progress.toStringAsFixed(0)}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8
                    ? AppColors.success
                    : progress >= 0.5
                        ? AppColors.primary
                        : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '₹${goal.currentAmount.toStringAsFixed(0)} of ₹${goal.targetAmount.toStringAsFixed(0)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
