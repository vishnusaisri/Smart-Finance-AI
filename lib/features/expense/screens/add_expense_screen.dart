import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/expense.dart';
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

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const AddExpenseScreen({super.key, this.initialCategory});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isImpulse = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add expenses')),
      );
      return;
    }

    final userProfile = ref.read(userProfileProvider);
    final expenses = ref.read(expensesListProvider);
    final symbol = userProfile.getCurrencySymbol();
    final enteredAmount = double.parse(_amountController.text);

    final now = DateTime.now();
    final currentMonthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final availableWalletBalance = userProfile.monthlyIncome - currentMonthExpenses;

    if (userProfile.monthlyIncome > 0 && enteredAmount > availableWalletBalance) {
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
            'Insufficient money in the wallet!\n\nYour available wallet balance is $symbol${availableWalletBalance.toStringAsFixed(2)}, but this expense is $symbol${enteredAmount.toStringAsFixed(2)}.\n\nDo you still want to save this expense?',
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

    final expense = Expense(
      id: const Uuid().v4(),
      userId: auth.uid,
      amount: enteredAmount,
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      isImpulse: _isImpulse,
    );

    await ref.read(expenseControllerProvider.notifier).addExpense(expense);

    if (mounted) {
      context.pop();
    }
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
    final categories = ExpenseCategoryService.getAllCategories();
    final userProfile = ref.watch(userProfileProvider);
    final expenses = ref.watch(expensesListProvider);
    final symbol = userProfile.getCurrencySymbol();

    final now = DateTime.now();
    final currentMonthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final availableWalletBalance = userProfile.monthlyIncome > 0
        ? (userProfile.monthlyIncome - currentMonthExpenses)
        : 0.0;

    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final isExceedingWallet = userProfile.monthlyIncome > 0 && enteredAmount > availableWalletBalance;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.addExpense,
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

              // Amount
              CustomTextField(
                label: AppStrings.expenseAmount,
                hint: '0.00',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixText: '$symbol ',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) => ValidationUtils.validateAmount(value, min: 0.01, max: 10000000, symbol: symbol),
                onChanged: (_) => setState(() {}),
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
                          'Insufficient money in the wallet! Amount ($symbol${enteredAmount.toStringAsFixed(0)}) exceeds available balance ($symbol${availableWalletBalance.toStringAsFixed(0)}).',
                          style: AppTextStyles.caption.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // Description
              CustomTextField(
                label: AppStrings.expenseNotes,
                hint: 'What was this expense for?',
                controller: _descriptionController,
                maxLines: 3,
                validator: (value) => ValidationUtils.validateDescription(value),
                onChanged: (value) {
                  // Auto-suggest category
                  if (_selectedCategory == null && value.length > 3) {
                    setState(() {
                      _selectedCategory = ExpenseCategoryService.suggestCategory(value);
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Selection
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
                children: [
                  if (_selectedCategory != null &&
                      !categories.any((c) => c.name.toLowerCase() == _selectedCategory!.toLowerCase()))
                    ChoiceChip(
                      label: Text(_selectedCategory!),
                      selected: true,
                      onSelected: (selected) {
                        if (!selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        }
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ...categories.map((category) {
                    final isSelected = _selectedCategory?.toLowerCase() == category.name.toLowerCase();
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
                  }),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date Selection
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

              // Impulse Toggle
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
                    Text(
                      'Mark as impulse purchase',
                      style: AppTextStyles.labelLarge,
                    ),
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

              // Save Button
              CustomButton(
                text: AppStrings.saveExpense,
                onPressed: _handleSave,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Cancel Button
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
  }
}
