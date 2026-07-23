import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../routes/app_routes.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Expense> expenses;

  const RecentTransactionsList({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.recentTransactions,
                  style: AppTextStyles.h5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to expense history screen
                  context.go(RouteNames.expenses);
                },
                child: Text(AppStrings.viewAll),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _TransactionTile(expense: expense);
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;

  const _TransactionTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _getCategoryIcon();
    final categoryColor = _getCategoryColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description.isNotEmpty
                      ? expense.description
                      : expense.category,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.category} • ${DateFormat('MMM d').format(expense.date)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '-\$${expense.amount.toStringAsFixed(2)}',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (expense.category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills & Utilities':
        return Icons.receipt;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Subscriptions':
        return Icons.repeat;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor() {
    switch (expense.category) {
      case 'Food & Dining':
        return AppColors.primary;
      case 'Transportation':
        return AppColors.secondary;
      case 'Shopping':
        return AppColors.accent;
      case 'Entertainment':
        return AppColors.success;
      case 'Bills & Utilities':
        return AppColors.warning;
      case 'Healthcare':
        return AppColors.danger;
      case 'Education':
        return const Color(0xFF8B5CF6);
      case 'Subscriptions':
        return const Color(0xFFEC4899);
      default:
        return AppColors.textSecondary;
    }
  }
}
