import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/expense.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/expense_controller.dart';
import '../services/expense_category_service.dart';

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
    expensesAsync.whenData((expenses) {
      final originalExpense = expenses.firstWhere((e) => e.id == widget.expenseId);
      
      final updatedExpense = originalExpense.copyWith(
        amount: double.parse(_amountController.text),
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
    
    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (expenses) {
        final expense = expenses.firstWhere(
          (e) => e.id == widget.expenseId,
          orElse: () => throw Exception('Expense not found'),
        );

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
                    AppStrings.editExpense,
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  CustomTextField(
                    label: AppStrings.expenseAmount,
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.attach_money),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
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
