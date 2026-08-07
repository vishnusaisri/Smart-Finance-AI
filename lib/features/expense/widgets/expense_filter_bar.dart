import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../services/expense_category_service.dart';
import '../controllers/expense_controller.dart';

class ExpenseFilterBar extends ConsumerWidget {
  const ExpenseFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(expenseFilterProvider);
    final categories = ExpenseCategoryService.getAllCategories();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All categories chip
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _CategoryChip(
              label: 'All',
              isSelected: filter.category == null,
              onTap: () {
                ref.read(expenseFilterControllerProvider.notifier).reset();
              },
            ),
          ),
          // Category chips
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _CategoryChip(
                label: category.name,
                icon: category.icon,
                color: category.color,
                isSelected: filter.category == category.name,
                onTap: () {
                  ref.read(expenseFilterControllerProvider.notifier).updateFilter(ExpenseFilter(
                    category: category.name,
                  ));
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _CategoryChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return Material(
      color: isSelected
          ? chipColor.withOpacity(0.2)
          : const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? chipColor : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? chipColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
