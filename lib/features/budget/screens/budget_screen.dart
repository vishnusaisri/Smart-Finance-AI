import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/budget_controller.dart';
import '../../../core/models/budget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context, ref),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => _buildLoadingSkeleton(),
        error: (error, stack) => _buildErrorState(error),
        data: (budgets) {
          if (budgets.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _buildBudgetCard(budget, ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Error loading budgets',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error.toString(),
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No budgets yet',
            style: AppTextStyles.h5,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first budget to start tracking your spending',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget, WidgetRef ref) {
    final isWarning = budget.isWarning;
    final isOverBudget = budget.isOverBudget;
    
    Color progressColor = Colors.green;
    if (isOverBudget) {
      progressColor = Colors.red;
    } else if (isWarning) {
      progressColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(budget.category, style: AppTextStyles.h6),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditBudgetDialog(context, ref, budget),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteConfirmation(context, ref, budget),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${budget.spent.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : null,
                  ),
                ),
                Text('of ₹${budget.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.amount > 0 ? (budget.spent / budget.amount).clamp(0.0, 1.0) : 0.0,
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: progressColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budget.percentageUsed.toStringAsFixed(0)}% used',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey.shade400),
                ),
                if (isOverBudget)
                  Text(
                    'Over by ₹${(budget.spent - budget.amount).toStringAsFixed(2)}',
                    style: AppTextStyles.caption.copyWith(color: Colors.red),
                  )
                else if (isWarning)
                  Text(
                    '₹${budget.remaining.toStringAsFixed(2)} left',
                    style: AppTextStyles.caption.copyWith(color: Colors.orange),
                  )
                else
                  Text(
                    '₹${budget.remaining.toStringAsFixed(2)} remaining',
                    style: AppTextStyles.caption.copyWith(color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    BudgetPeriod selectedPeriod = BudgetPeriod.monthly;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create budgets')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g., Food, Shopping, Entertainment',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  hintText: 'e.g., 50000',
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<BudgetPeriod>(
                value: selectedPeriod,
                decoration: const InputDecoration(labelText: 'Period'),
                items: BudgetPeriod.values.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period.name.capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPeriod = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid budget amount')),
                    );
                    return;
                  }
                  
                  final budget = Budget(
                    id: const Uuid().v4(),
                    userId: currentUser.uid,
                    category: categoryController.text,
                    amount: amount,
                    spent: 0,
                    period: selectedPeriod,
                    startDate: DateTime.now(),
                  );
                  ref.read(budgetProvider.notifier).saveBudget(budget);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget created successfully')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, Budget budget) {
    final categoryController = TextEditingController(text: budget.category);
    final amountController = TextEditingController(text: budget.amount.toString());
    BudgetPeriod selectedPeriod = budget.period;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<BudgetPeriod>(
                value: selectedPeriod,
                decoration: const InputDecoration(labelText: 'Period'),
                items: BudgetPeriod.values.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period.name.capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPeriod = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedBudget = budget.copyWith(
                  category: categoryController.text,
                  amount: double.tryParse(amountController.text) ?? budget.amount,
                  period: selectedPeriod,
                  updatedAt: DateTime.now(),
                );
                ref.read(budgetProvider.notifier).saveBudget(updatedBudget);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the budget for ${budget.category}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteBudget(budget.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
