import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/glass_card.dart';

class FinancialGoalsForm extends ConsumerWidget {
  const FinancialGoalsForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Goals', style: AppTextStyles.h5),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Monthly Income',
              prefixText: '₹',
              border: OutlineInputBorder(),
            ),
            initialValue: '5000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Savings Goal',
              prefixText: '₹',
              border: OutlineInputBorder(),
            ),
            initialValue: '1000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Emergency Fund Target',
              prefixText: '₹',
              border: OutlineInputBorder(),
            ),
            initialValue: '10000',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
