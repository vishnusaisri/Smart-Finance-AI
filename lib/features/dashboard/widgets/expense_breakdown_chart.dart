import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/expense.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

class ExpenseBreakdownChart extends StatelessWidget {
  final Map<String, double> categoryBreakdown;

  const ExpenseBreakdownChart({
    super.key,
    required this.categoryBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryBreakdown.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final total = categoryBreakdown.values.fold<double>(0, (sum, val) => sum + val);
    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 300;
        final chartHeight = isSmall ? 180.0 : 250.0;

        return Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: isSmall ? 40 : 50,
                  sections: sortedCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final percentage = (category.value / total) * 100;

                    // Only show title on larger sections (> 10%)
                    final showTitle = percentage > 10 && !isSmall;

                    return PieChartSectionData(
                      value: category.value,
                      title: showTitle ? '${percentage.toStringAsFixed(0)}%' : '',
                      color: colors[index % colors.length],
                      radius: isSmall ? 50 : 70,
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
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: sortedCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final percentage = (category.value / total) * 100;

                return Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Flexible(
                      child: Text(
                        '${category.key} (${percentage.toStringAsFixed(0)}%)',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: isSmall ? 11 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
