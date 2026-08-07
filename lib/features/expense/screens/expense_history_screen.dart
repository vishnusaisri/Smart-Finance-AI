import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_tile.dart';
import '../widgets/expense_filter_bar.dart';
import '../widgets/expense_summary_card.dart';
import '../../../routes/app_routes.dart';

class ExpenseHistoryScreen extends ConsumerWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final stats = ref.watch(expenseStatsProvider);

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: AppSpacing.lg),
            Text('Error loading expenses', style: AppTextStyles.h5),
            const SizedBox(height: AppSpacing.md),
            CustomButton(
              text: AppStrings.tryAgain,
              onPressed: () => ref.read(expenseControllerProvider.notifier).loadExpenses(),
            ),
          ],
        ),
      ),
      data: (_) {
        final filteredExpenses = ref.watch(filteredExpensesProvider);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.expenses,
                    style: AppTextStyles.h2,
                  ),
                  CustomButton(
                    text: 'Add Expense',
                    icon: Icons.add,
                    onPressed: () {
                      context.push('${RouteNames.expenses}/add');
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Summary Card
              ExpenseSummaryCard(
                totalExpenses: stats.total,
                transactionCount: stats.count,
                averageExpense: stats.average,
                period: 'All Time',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Filter Bar
              const ExpenseFilterBar(),
              const SizedBox(height: AppSpacing.lg),

              // Expense List
              if (filteredExpenses.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        AppStrings.noExpenses,
                        style: AppTextStyles.h5,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredExpenses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return ExpenseTile(
                      expense: expense,
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Expense'),
                            content: const Text('Are you sure you want to delete this expense?'),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text(AppStrings.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
                                  context.pop();
                                },
                                child: const Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
