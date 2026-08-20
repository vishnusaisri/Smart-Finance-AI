import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validation_utils.dart';
import '../controllers/expense_controller.dart';
import '../services/expense_category_service.dart';

import '../../profile/providers/profile_providers.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final String expenseId;

  const EditExpenseScreen({
    super.key,
    required this.expenseId,
  });

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  late DateTime _selectedDate;
  late bool _isImpulse;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // Load expense data
    final expensesAsync = ref.read(expensesProvider);
    expensesAsync.whenData((expenses) {
      final expense = expenses.firstWhere((e) => e.id == widget.expenseId);
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
      _isImpulse = expense.isImpulse;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final expensesAsync = ref.read(expensesProvider);
    final userProfile = ref.read(userProfileProvider);
    final symbol = userProfile.getCurrencySymbol();
    final newAmount = double.parse(_amountController.text);

    expensesAsync.whenData((expenses) async {
      final originalExpense = expenses.firstWhere((e) => e.id == widget.expenseId);

      final now = DateTime.now();
      final otherMonthExpenses = expenses
          .where((e) => e.id != widget.expenseId && e.date.year == now.year && e.date.month == now.month)
          .fold<double>(0, (sum, e) => sum + e.amount);
      final availableWalletBalance = userProfile.monthlyIncome - otherMonthExpenses;

      if (userProfile.monthlyIncome > 0 && newAmount > availableWalletBalance) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Insufficient Money in Wallet', style: AppTextStyles.h4),
              ],
            ),
            content: Text(
              'Insufficient money in the wallet!\n\nYour available wallet balance is $symbol${availableWalletBalance.toStringAsFixed(2)}, but updated expense is $symbol${newAmount.toStringAsFixed(2)}.\n\nDo you still want to save this update?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Proceed Anyway'),
              ),
            ],
          ),
        );

        if (shouldProceed != true) return;
      }

      final updatedExpense = originalExpense.copyWith(
        amount: newAmount,
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        isImpulse: _isImpulse,
        updatedAt: DateTime.now(),
      );

      ref.read(expenseControllerProvider.notifier).updateExpense(updatedExpense);
      
      if (mounted) {
        context.pop();
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final userProfile = ref.watch(userProfileProvider);
    final symbol = userProfile.getCurrencySymbol();

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (expenses) {
        final categories = ExpenseCategoryService.getAllCategories();
        
        final now = DateTime.now();
        final otherMonthExpenses = expenses
            .where((e) => e.id != widget.expenseId && e.date.year == now.year && e.date.month == now.month)
            .fold<double>(0, (sum, e) => sum + e.amount);
        final availableWalletBalance = userProfile.monthlyIncome > 0
            ? (userProfile.monthlyIncome - otherMonthExpenses)
            : 0.0;

        final newAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
        final isExceedingWallet = userProfile.monthlyIncome > 0 && newAmount > availableWalletBalance;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.editExpense,
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Wallet Balance Banner
                  GlassCard(
                    child: Row(
                      children: [
                        Icon(
                          isExceedingWallet ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined,
                          color: isExceedingWallet ? AppColors.warning : AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available Wallet Balance', style: AppTextStyles.caption),
                            Text(
                              '$symbol${availableWalletBalance.toStringAsFixed(2)}',
                              style: AppTextStyles.h4.copyWith(
                                color: isExceedingWallet ? AppColors.warning : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  CustomTextField(
                    label: AppStrings.expenseAmount,
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixText: '$symbol ',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) => setState(() {}),
                    validator: (value) => ValidationUtils.validateAmount(value, min: 0.01, max: 10000000, symbol: symbol),
                  ),
                  if (isExceedingWallet) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Insufficient money in the wallet! Amount ($symbol${newAmount.toStringAsFixed(0)}) exceeds available balance ($symbol${availableWalletBalance.toStringAsFixed(0)}).',
                              style: AppTextStyles.caption.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),

                  CustomTextField(
                    label: AppStrings.expenseNotes,
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    AppStrings.expenseCategory,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category.name;
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category.name : null;
                          });
                        },
                        selectedColor: category.color.withOpacity(0.2),
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? category.color : AppColors.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  GlassCard(
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: AppTextStyles.labelLarge,
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  GlassCard(
                    onTap: () {
                      setState(() {
                        _isImpulse = !_isImpulse;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _isImpulse ? Icons.flash_on : Icons.flash_off,
                          color: _isImpulse ? Colors.orange : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Text('Mark as impulse purchase'),
                        const Spacer(),
                        Switch(
                          value: _isImpulse,
                          onChanged: (value) {
                            setState(() {
                              _isImpulse = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  CustomButton(
                    text: AppStrings.save,
                    onPressed: _handleSave,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  CustomButton(
                    text: AppStrings.cancel,
                    type: ButtonType.secondary,
                    onPressed: () => context.pop(),
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
