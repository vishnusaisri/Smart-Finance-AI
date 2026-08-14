import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../profile/providers/profile_providers.dart';

class ExpenseSummaryCard extends ConsumerWidget {
  final double totalExpenses;
  final int transactionCount;
  final double averageExpense;
  final String? period;

  const ExpenseSummaryCard({
    super.key,
    required this.totalExpenses,
    required this.transactionCount,
    required this.averageExpense,
    this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final symbol = userProfile.getCurrencySymbol();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (period != null) ...[
            Text(
              period!,
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: 'Total',
                value: '$symbol${totalExpenses.toStringAsFixed(2)}',
                color: AppColors.danger,
              ),
              _StatItem(
                label: 'Transactions',
                value: transactionCount.toString(),
                color: AppColors.primary,
              ),
              _StatItem(
                label: 'Average',
                value: '$symbol${averageExpense.toStringAsFixed(2)}',
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
