import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../../core/models/expense.dart';

class ImpulseScreen extends ConsumerWidget {
  const ImpulseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Impulse Insights',
                style: AppTextStyles.h3,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: AppSpacing.xl),
              expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading insights')),
                data: (expenses) => _buildImpulseContent(expenses),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpulseContent(List<dynamic> expenses) {
    if (expenses.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(Icons.flash_on_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text('No expense data yet', style: AppTextStyles.h5),
            const SizedBox(height: AppSpacing.sm),
            Text('Add expenses to see impulse insights', style: AppTextStyles.bodyMedium),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    // Analyze for impulse patterns
    final impulseScore = _calculateImpulseScore(expenses);
    final impulseCategories = _identifyImpulseCategories(expenses);
    final weekendSpending = _calculateWeekendSpending(expenses);

    return Column(
      children: [
        _buildImpulseScoreCard(impulseScore),
        const SizedBox(height: AppSpacing.xl),
        _buildImpulseCategories(impulseCategories),
        const SizedBox(height: AppSpacing.xl),
        _buildWeekendAnalysis(weekendSpending),
        const SizedBox(height: AppSpacing.xl),
        _buildRecommendations(impulseScore),
      ],
    );
  }

  double _calculateImpulseScore(List<dynamic> expenses) {
    if (expenses.isEmpty) return 0.0;
    
    final expenseList = expenses.whereType<Expense>().toList();
    if (expenseList.isEmpty) return 0.0;
    
    final totalAmount = expenseList.fold<double>(0, (sum, e) => sum + e.amount);
    if (totalAmount <= 0) return 0.0;

    // 1. Directly flagged impulse expenses
    final impulseFlaggedTotal = expenseList
        .where((e) => e.isImpulse)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final flaggedRatio = (impulseFlaggedTotal / totalAmount) * 100;

    // 2. High-risk categories spending ratio
    final potentialImpulseCategories = {
      'entertainment', 'shopping', 'dining', 'food', 'hobbies'
    };
    final highRiskTotal = expenseList
        .where((e) => potentialImpulseCategories.contains(e.category.toLowerCase().trim()))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final highRiskRatio = (highRiskTotal / totalAmount) * 100;

    // 3. Weekend spending ratio
    final weekendTotal = expenseList
        .where((e) => e.date.weekday == DateTime.saturday || e.date.weekday == DateTime.sunday)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final weekendRatio = (weekendTotal / totalAmount) * 100;

    // Weighting: Direct flagged impulse (50%), High-risk category (35%), Weekend spending (15%)
    final score = (flaggedRatio * 0.50) + (highRiskRatio * 0.35) + (weekendRatio * 0.15);
    return score.clamp(0.0, 100.0);
  }

  List<String> _identifyImpulseCategories(List<dynamic> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    final total = categoryTotals.values.fold<double>(0, (sum, val) => sum + val);
    final impulseCategories = <String>[];
    
    // Categories that might indicate impulse spending
    final potentialImpulseCategories = [
      'Entertainment', 'Shopping', 'Dining', 'Food', 'Hobbies'
    ];
    
    for (final category in potentialImpulseCategories) {
      if (categoryTotals.containsKey(category)) {
        final percentage = (categoryTotals[category]! / total) * 100;
        if (percentage > 15) {
          impulseCategories.add(category);
        }
      }
    }
    
    return impulseCategories;
  }

  double _calculateWeekendSpending(List<dynamic> expenses) {
    final weekendExpenses = expenses.where((e) => 
      e.date.weekday == DateTime.saturday || e.date.weekday == DateTime.sunday
    ).toList();
    
    final weekendTotal = weekendExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    
    return total > 0 ? (weekendTotal / total) * 100 : 0;
  }

  Widget _buildImpulseScoreCard(double score) {
    final isLow = score < 30;
    final isHigh = score > 70;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLow ? Icons.check_circle : isHigh ? Icons.warning : Icons.info,
                color: isLow ? AppColors.success : isHigh ? AppColors.warning : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Impulse Spending Score', style: AppTextStyles.h5),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLow ? AppColors.success.withValues(alpha: 0.2) : isHigh ? AppColors.warning.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
                border: Border.all(
                  color: isLow ? AppColors.success : isHigh ? AppColors.warning : AppColors.primary,
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: AppTextStyles.h3.copyWith(
                        color: isLow ? AppColors.success : isHigh ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isLow ? 'Low impulse spending - Great!' : isHigh ? 'High impulse detected' : 'Moderate impulse spending',
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildImpulseCategories(List<String> categories) {
    if (categories.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('No high-risk categories detected', style: AppTextStyles.labelMedium),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text('High-Risk Categories', style: AppTextStyles.h5),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(category, style: AppTextStyles.labelMedium),
                ),
                Text('Review', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ],
            ),
          )).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildWeekendAnalysis(double weekendPercentage) {
    final isHigh = weekendPercentage > 40;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.weekend, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Text('Weekend Spending', style: AppTextStyles.h5),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: weekendPercentage / 100,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
            color: isHigh ? AppColors.warning : AppColors.success,
            minHeight: 8,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${weekendPercentage.toStringAsFixed(0)}% of spending', style: AppTextStyles.labelMedium),
              Text(
                isHigh ? 'High' : 'Normal',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isHigh ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecommendations(double score) {
    final recommendations = <String>[];
    
    if (score > 70) {
      recommendations.addAll([
        'Use the 24-hour rule before purchases over ₹1,000',
        'Set a weekly spending limit for entertainment',
        'Track weekend spending more carefully',
        'Unsubscribe from marketing emails',
      ]);
    } else if (score > 40) {
      recommendations.addAll([
        'Review your shopping habits weekly',
        'Set spending alerts for high-risk categories',
        'Consider a no-spend weekend challenge',
      ]);
    } else {
      recommendations.add('Keep up the great spending habits!');
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Text('Recommendations', style: AppTextStyles.h5),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...recommendations.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.labelMedium,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
