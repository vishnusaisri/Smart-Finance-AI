import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../profile/providers/profile_providers.dart';

class PredictionsScreen extends ConsumerWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Predictions',
                style: AppTextStyles.h3,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: AppSpacing.xl),
              expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading predictions')),
                data: (expenses) => _buildPredictionContent(expenses, userProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionContent(List<dynamic> expenses, userProfile) {
    if (expenses.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(Icons.trending_up_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text('No expense data yet', style: AppTextStyles.h5),
            const SizedBox(height: AppSpacing.sm),
            Text('Add expenses to see predictions', style: AppTextStyles.bodyMedium),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final monthlyIncome = userProfile.monthlyIncome;
    final savingsRate = monthlyIncome > 0 ? ((monthlyIncome - totalExpenses) / monthlyIncome) * 100 : 0.0;

    return Column(
      children: [
        _buildSavingsPrediction(savingsRate, monthlyIncome),
        const SizedBox(height: AppSpacing.xl),
        _buildSpendingForecast(expenses),
        const SizedBox(height: AppSpacing.xl),
        _buildGoalPrediction(userProfile.savingsGoal, totalExpenses),
      ],
    );
  }

  Widget _buildSavingsPrediction(double savingsRate, double monthlyIncome) {
    final projectedAnnualSavings = (monthlyIncome * (savingsRate / 100)) * 12;
    final isPositive = savingsRate >= 20;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.savings : Icons.warning,
                color: isPositive ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Savings Projection', style: AppTextStyles.h5),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _PredictionCard(
                  label: 'Current Rate',
                  value: '${savingsRate.toStringAsFixed(1)}%',
                  subtitle: 'of income',
                  color: savingsRate >= 20 ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PredictionCard(
                  label: 'Annual Savings',
                  value: '₹${projectedAnnualSavings.toStringAsFixed(0)}',
                  subtitle: 'projected',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSpendingForecast(List<dynamic> expenses) {
    final monthlyTotal = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final projectedMonthly = monthlyTotal * 1.05; // 5% inflation estimate

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(
        children: [
          Icon(Icons.show_chart, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text('Spending Forecast', style: AppTextStyles.h5),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      _ForecastRow(
        label: 'This Month',
        value: '₹${monthlyTotal.toStringAsFixed(0)}',
        isCurrent: true,
      ),
      const SizedBox(height: AppSpacing.sm),
      _ForecastRow(
        label: 'Next Month (Est.)',
        value: '₹${projectedMonthly.toStringAsFixed(0)}',
        isCurrent: false,
      ),
      const SizedBox(height: AppSpacing.sm),
      _ForecastRow(
        label: '6 Months (Est.)',
        value: '₹${(projectedMonthly * 6).toStringAsFixed(0)}',
        isCurrent: false,
      ),
    ],
  ),
).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildGoalPrediction(double savingsGoal, double currentSavings) {
    final progress = savingsGoal > 0 ? (currentSavings / savingsGoal) * 100 : 0;
    final monthsToGoal = savingsGoal > 0 && currentSavings < savingsGoal 
        ? ((savingsGoal - currentSavings) / (currentSavings / 12)).ceil() 
        : 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Text('Goal Progress', style: AppTextStyles.h5),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
            color: AppColors.accent,
            minHeight: 8,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${progress.toStringAsFixed(0)}% Complete', style: AppTextStyles.labelMedium),
              if (progress < 100)
                Text('~$monthsToGoal months to goal', style: AppTextStyles.bodySmall)
              else
                Text('Goal reached!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _PredictionCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _PredictionCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.h4.copyWith(color: color),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCurrent;

  const _ForecastRow({
    required this.label,
    required this.value,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
