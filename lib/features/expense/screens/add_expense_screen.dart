import 'package:flutter/material.dart';
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

    final expense = Expense(
      id: const Uuid().v4(),
      userId: auth.uid,
      amount: double.parse(_amountController.text),
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
              const SizedBox(height: AppSpacing.xl),

              // Amount
              CustomTextField(
                label: AppStrings.expenseAmount,
                hint: '0.00',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixText: '₹ ',
                validator: (value) => ValidationUtils.validateAmount(value, min: 0.01, max: 1000000),
              ),
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
