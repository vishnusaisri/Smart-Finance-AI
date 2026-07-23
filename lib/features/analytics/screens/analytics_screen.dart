import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../expense/controllers/expense_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

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
                'Analytics',
                style: AppTextStyles.h3,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: AppSpacing.xl),
              expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading analytics')),
                data: (expenses) => _buildAnalyticsContent(expenses),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(List<dynamic> expenses) {
    if (expenses.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text('No expense data yet', style: AppTextStyles.h5),
            const SizedBox(height: AppSpacing.sm),
            Text('Add expenses to see analytics', style: AppTextStyles.bodyMedium),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    final categoryBreakdown = <String, double>{};
    for (final expense in expenses) {
      categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] ?? 0) + expense.amount;
    }

    final total = categoryBreakdown.values.fold<double>(0, (sum, val) => sum + val);
    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        _buildSummaryCards(total, expenses.length),
        const SizedBox(height: AppSpacing.xl),
        _buildCategoryBreakdown(sortedCategories, total),
        const SizedBox(height: AppSpacing.xl),
        _buildMonthlyTrend(expenses),
      ],
    );
  }

  Widget _buildSummaryCards(double total, int count) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Spending', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('\$${total.toStringAsFixed(0)}', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.xs),
                Text('$count transactions', style: AppTextStyles.bodySmall),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avg Transaction', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('\$${(total / count).toStringAsFixed(0)}', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.xs),
                Text('Per expense', style: AppTextStyles.bodySmall),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(List<MapEntry<String, double>> sortedCategories, double total) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: AppTextStyles.h5),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: sortedCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final percentage = (category.value / total) * 100;

                  return PieChartSectionData(
                    value: category.value,
                    title: percentage > 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                    color: colors[index % colors.length],
                    radius: 70,
                    titleStyle: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    titlePositionPercentageOffset: 0.6,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage = (category.value / total) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      category.key,
                      style: AppTextStyles.labelMedium,
                    ),
                  ),
                  Text('\$${category.value.toStringAsFixed(0)}', style: AppTextStyles.labelMedium),
                  const SizedBox(width: AppSpacing.sm),
                  Text('${percentage.toStringAsFixed(0)}%', style: AppTextStyles.bodySmall),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMonthlyTrend(List<dynamic> expenses) {
    final monthlyData = <String, double>{};
    for (final expense in expenses) {
      final key = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyData[key] = (monthlyData[key] ?? 0) + expense.amount;
    }

    final sortedMonths = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Trend', style: AppTextStyles.h5),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedMonths.isEmpty ? 0 : sortedMonths.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: sortedMonths.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: AppColors.primary,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final monthStr = value.toString();
                        if (monthStr.contains('-')) {
                          final parts = monthStr.split('-');
                          return Text('${parts[1]}/${parts[0].substring(2)}', style: AppTextStyles.labelSmall);
                        }
                        return Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
