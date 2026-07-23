import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';
import '../providers/profile_providers.dart';

class FinancialGoalsForm extends ConsumerStatefulWidget {
  const FinancialGoalsForm({super.key});

  @override
  ConsumerState<FinancialGoalsForm> createState() => _FinancialGoalsFormState();
}

class _FinancialGoalsFormState extends ConsumerState<FinancialGoalsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(financialGoalsFormProvider);
    final userProfile = ref.watch(userProfileProvider);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.green[400]),
                  const SizedBox(width: 12),
                  Text(
                    'Financial Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Monthly income field
              TextFormField(
                initialValue: userProfile.monthlyIncome.toString(),
                decoration: InputDecoration(
                  labelText: 'Monthly Income',
                  hintText: 'Enter your monthly income',
                  prefixIcon: Text(
                    userProfile.getCurrencySymbol(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  ref.read(financialGoalsFormProvider.notifier).updateMonthlyIncome(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Monthly income is required';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              if (formState['monthlyIncomeError'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formState['monthlyIncomeError']!,
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Savings goal field
              TextFormField(
                initialValue: userProfile.savingsGoal.toString(),
                decoration: InputDecoration(
                  labelText: 'Monthly Savings Goal',
                  hintText: 'Enter your monthly savings goal',
                  prefixIcon: Text(
                    userProfile.getCurrencySymbol(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  ref.read(financialGoalsFormProvider.notifier).updateSavingsGoal(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Savings goal is required';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid non-negative number';
                  }
                  return null;
                },
              ),
              if (formState['savingsGoalError'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formState['savingsGoalError']!,
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Savings rate indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: userProfile.getSavingsRate() >= 0.2 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Savings Rate',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            '${(userProfile.getSavingsRate() * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: userProfile.getSavingsRate() >= 0.2 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final formData = ref.read(financialGoalsFormProvider.notifier).getFormData();
                      ref.read(userProfileProvider.notifier).updateFinancialGoals(
                        monthlyIncome: formData['monthlyIncome']!,
                        savingsGoal: formData['savingsGoal']!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Financial goals updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Goals'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}