import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/expense_controller.dart';
import '../services/expense_category_service.dart';
import '../../../routes/app_routes.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expensesProvider);

    return expenseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: AppSpacing.lg),
            Text('Error loading expense', style: AppTextStyles.h5),
          ],
        ),
      ),
      data: (expenses) {
        final expense = expenses.firstWhere(
          (e) => e.id == expenseId,
          orElse: () => throw Exception('Expense not found'),
        );

        return _ExpenseDetailContent(expense: expense);
      },
    );
  }
}

class _ExpenseDetailContent extends StatelessWidget {
  final Expense expense;

  const _ExpenseDetailContent({required this.expense});

  @override
  Widget build(BuildContext context) {
    final categoryColor = ExpenseCategoryService.getCategoryColor(expense.category);
    final categoryIcon = ExpenseCategoryService.getCategoryIcon(expense.category);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Header
          Center(
            child: Column(
              children: [
                Text(
                  '-\$${expense.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.display2.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryIcon, color: categoryColor, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        expense.category,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Details Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: DateFormat('EEEE, MMMM d, yyyy').format(expense.date),
                ),
                const Divider(),
                _DetailRow(
                  icon: Icons.description,
                  label: 'Description',
                  value: expense.description.isNotEmpty
                      ? expense.description
                      : 'No description',
                ),
                const Divider(),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Added',
                  value: DateFormat('MMM d, yyyy h:mm a').format(expense.createdAt),
                ),
                if (expense.isImpulse) ...[
                  const Divider(),
                  _DetailRow(
                    icon: Icons.flash_on,
                    label: 'Type',
                    value: 'Impulse Purchase',
                    valueColor: AppColors.warning,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Edit',
                  icon: Icons.edit,
                  type: ButtonType.secondary,
                  onPressed: () {
                    context.push('/expenses/${expense.id}/edit');
                  },
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomButton(
                  text: 'Delete',
                  icon: Icons.delete,
                  type: ButtonType.danger,
                  onPressed: () {
                    _showDeleteDialog(context, expense);
                  },
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              // Delete expense
              context.pop();
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Text(
            '$label:',
            style: AppTextStyles.labelMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
