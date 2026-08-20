import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../profile/providers/profile_providers.dart';

class PredictionsScreen extends ConsumerWidget {
  const PredictionsScreen({super.key});

  String _formatAmount(double amount, String currencySymbol) {
    final formatter = NumberFormat.decimalPattern();
    return '$currencySymbol${formatter.format(amount.round())}';
  }

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
    final netMonthlySavings = (monthlyIncome - totalExpenses).clamp(0.0, double.infinity);
    final savingsRate = monthlyIncome > 0 ? (netMonthlySavings / monthlyIncome) * 100 : 0.0;
    final currencySymbol = userProfile.getCurrencySymbol();

    return Column(
      children: [
        _buildSavingsPrediction(savingsRate, monthlyIncome, netMonthlySavings, currencySymbol),
        const SizedBox(height: AppSpacing.xl),
        _buildSpendingForecast(expenses, currencySymbol),
        const SizedBox(height: AppSpacing.xl),
        _buildGoalPrediction(userProfile.savingsGoal, netMonthlySavings, currencySymbol),
      ],
    );
  }

  Widget _buildSavingsPrediction(double savingsRate, double monthlyIncome, double netMonthlySavings, String currencySymbol) {
    final projectedAnnualSavings = netMonthlySavings * 12;
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
                  value: _formatAmount(projectedAnnualSavings, currencySymbol),
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

  Widget _buildSpendingForecast(List<dynamic> expenses, String currencySymbol) {
    final now = DateTime.now();
    final currentMonthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
    
    // Monthly history calculation
    final monthlyTotals = <String, double>{};
    for (final expense in expenses) {
      final key = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + expense.amount;
    }
    
    final averageMonthly = monthlyTotals.isNotEmpty
        ? monthlyTotals.values.fold<double>(0, (a, b) => a + b) / monthlyTotals.length
        : currentMonthExpenses;

    final nextMonthEst = averageMonthly > 0 ? averageMonthly : currentMonthExpenses;

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
            value: _formatAmount(currentMonthExpenses, currencySymbol),
            isCurrent: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ForecastRow(
            label: 'Next Month (Est.)',
            value: _formatAmount(nextMonthEst, currencySymbol),
            isCurrent: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ForecastRow(
            label: '6 Months (Est.)',
            value: _formatAmount(nextMonthEst * 6, currencySymbol),
            isCurrent: false,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildGoalPrediction(double savingsGoal, double netMonthlySavings, String currencySymbol) {
    final monthsToGoal = (savingsGoal > 0 && netMonthlySavings > 0)
        ? (savingsGoal / netMonthlySavings).ceil()
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
            value: savingsGoal > 0 ? (netMonthlySavings / savingsGoal).clamp(0.0, 1.0) : 0,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
            color: AppColors.accent,
            minHeight: 8,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_formatAmount(netMonthlySavings, currencySymbol)} / ${_formatAmount(savingsGoal, currencySymbol)} per mo', style: AppTextStyles.labelMedium),
              if (savingsGoal > 0 && netMonthlySavings > 0)
                Text('~$monthsToGoal months to reach target', style: AppTextStyles.bodySmall)
              else if (savingsGoal > 0 && netMonthlySavings <= 0)
                Text('Increase income or lower spend', style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning))
              else
                Text('Set a goal in Profile', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
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
