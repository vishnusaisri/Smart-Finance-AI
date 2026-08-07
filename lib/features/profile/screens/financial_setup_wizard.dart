import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/cache_service.dart';
import '../providers/profile_providers.dart';
import '../../auth/services/user_profile_service.dart';
import '../../../core/models/user_profile.dart';

class FinancialSetupWizard extends ConsumerStatefulWidget {
  const FinancialSetupWizard({super.key});

  @override
  ConsumerState<FinancialSetupWizard> createState() => _FinancialSetupWizardState();
}

class _FinancialSetupWizardState extends ConsumerState<FinancialSetupWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Personal Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 2: Income & Savings
  final _monthlyIncomeController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  final _monthlyBudgetController = TextEditingController();

  // Step 3: Financial Goals
  final List<String> _selectedGoals = [];
  final _customGoalController = TextEditingController();

  // Step 4: Spending Habits
  String _spendingHabit = 'Moderate';
  final List<String> _spendingHabits = ['Conservative', 'Moderate', 'Aggressive'];

  // Step 5: Investment Interest
  String _investmentInterest = 'Medium';
  final List<String> _investmentLevels = ['Low', 'Medium', 'High', 'Very High'];

  // Step 6: Debt Status
  String _debtStatus = 'None';
  final List<String> _debtOptions = ['None', 'Low', 'Medium', 'High'];
  final _debtAmountController = TextEditingController();

  // Step 7: Emergency Fund
  final _emergencyFundController = TextEditingController();

  // Currency (default INR)
  String _currency = 'INR';
  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillGoogleData();
  }

  Future<void> _prefillGoogleData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _fullNameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _monthlyIncomeController.dispose();
    _savingsGoalController.dispose();
    _monthlyBudgetController.dispose();
    _customGoalController.dispose();
    _debtAmountController.dispose();
    _emergencyFundController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeSetup() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = FirebaseAuth.instance.currentUser;
      final monthlyIncome = double.tryParse(_monthlyIncomeController.text) ?? 0.0;
      final savingsGoal = double.tryParse(_savingsGoalController.text) ?? 0.0;
      final monthlyBudget = double.tryParse(_monthlyBudgetController.text) ?? 0.0;
      final emergencyFund = double.tryParse(_emergencyFundController.text) ?? 0.0;
      final debtAmount = double.tryParse(_debtAmountController.text) ?? 0.0;

      // Create financial goals
      final goals = _selectedGoals.map((goal) => FinancialGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString() + goal,
        name: goal,
        targetAmount: savingsGoal,
        currentAmount: 0,
      )).toList();

      if (auth != null) {
        final userProfileService = ref.read(userProfileServiceProvider);
        
        // Create comprehensive user profile
        final userProfile = UserProfile(
          uid: auth.uid,
          email: auth.email ?? _emailController.text,
          fullName: _fullNameController.text,
          avatarUrl: auth.photoURL,
          monthlyIncome: monthlyIncome,
          currency: _currency,
          goals: goals,
          savingsGoal: savingsGoal,
          preferences: {
            'spendingHabit': _spendingHabit,
            'investmentInterest': _investmentInterest,
            'debtStatus': _debtStatus,
            'debtAmount': debtAmount,
            'emergencyFundTarget': emergencyFund,
            'monthlyBudget': monthlyBudget,
            'onboardingCompleted': true,
          },
        );

        await userProfileService.saveUserProfile(userProfile);
        final profile = await userProfileService.getUserProfile(auth.uid);
        if (profile != null) {
          await ref.read(userProfileProvider.notifier).updateProfile(profile);
        }
        
        // Mark financial setup as complete
        final cacheService = ref.read(cacheServiceProvider);
        await cacheService.markFinancialSetupComplete();
      } else {
        // Mock mode fallback
        final currentProfile = ref.read(userProfileProvider);
        final updated = currentProfile.copyWith(
          fullName: _fullNameController.text,
          monthlyIncome: monthlyIncome,
          currency: _currency,
          goals: goals,
          savingsGoal: savingsGoal,
          preferences: {
            'spendingHabit': _spendingHabit,
            'investmentInterest': _investmentInterest,
            'debtStatus': _debtStatus,
            'debtAmount': debtAmount,
            'emergencyFundTarget': emergencyFund,
            'monthlyBudget': monthlyBudget,
            'onboardingCompleted': true,
          },
        );
        await ref.read(userProfileProvider.notifier).updateProfile(updated);
      }
    } catch (e) {
      debugPrint('Error during financial setup: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go(RouteNames.dashboard);
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _fullNameController.text.isNotEmpty && _emailController.text.isNotEmpty;
      case 1:
        return _monthlyIncomeController.text.isNotEmpty && 
               _savingsGoalController.text.isNotEmpty &&
               _monthlyBudgetController.text.isNotEmpty;
      case 2:
        return _selectedGoals.isNotEmpty;
      case 3:
        return true;
      case 4:
        return true;
      case 5:
        if (_debtStatus != 'None' && _debtStatus != 'Low') {
          return _debtAmountController.text.isNotEmpty;
        }
        return true;
      case 6:
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            
            // Page view for steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildIncomeSavingsStep(),
                  _buildFinancialGoalsStep(),
                  _buildSpendingHabitsStep(),
                  _buildInvestmentStep(),
                  _buildDebtStatusStep(),
                  _buildEmergencyFundStep(),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 6 ? AppSpacing.sm : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : isCurrent
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Step ${_currentStep + 1} of 7',
            style: AppTextStyles.caption.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Back',
                onPressed: _previousStep,
                fullWidth: true,
                type: ButtonType.secondary,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: CustomButton(
              text: _currentStep == 6 ? 'Complete Setup' : 'Next',
              onPressed: _validateCurrentStep() ? _nextStep : null,
              fullWidth: true,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return _buildStepContent(
      title: 'Personal Information',
      description: 'Let\'s start with your basic details',
      children: [
        CustomTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _fullNameController,
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required field';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required field';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIncomeSavingsStep() {
    return _buildStepContent(
      title: 'Income & Savings',
      description: 'Tell us about your financial situation',
      children: [
        CustomTextField(
          label: 'Monthly Income (₹)',
          hint: 'e.g., 50000',
          controller: _monthlyIncomeController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.account_balance_wallet),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required field';
            if (double.tryParse(value) == null) return 'Must be a number';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Monthly Savings Goal (₹)',
          hint: 'e.g., 10000',
          controller: _savingsGoalController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.savings),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required field';
            if (double.tryParse(value) == null) return 'Must be a number';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Monthly Budget (₹)',
          hint: 'e.g., 40000',
          controller: _monthlyBudgetController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.account_balance_wallet),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required field';
            if (double.tryParse(value) == null) return 'Must be a number';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<String>(
          initialValue: _currency,
          decoration: const InputDecoration(
            labelText: 'Preferred Currency',
            prefixIcon: Icon(Icons.currency_rupee),
          ),
          items: _currencies.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _currency = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildFinancialGoalsStep() {
    final predefinedGoals = [
      'Emergency Fund',
      'Retirement',
      'Home Purchase',
      'Travel',
      'Education',
      'Debt Repayment',
      'Investment',
    ];

    return _buildStepContent(
      title: 'Financial Goals',
      description: 'Select your financial goals (select at least one)',
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: predefinedGoals.map((goal) {
            final isSelected = _selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGoals.add(goal);
                  } else {
                    _selectedGoals.remove(goal);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Custom Goal (optional)',
          hint: 'Add a custom financial goal',
          controller: _customGoalController,
          prefixIcon: const Icon(Icons.add),
          onSubmitted: (value) {
            if (value.isNotEmpty && !_selectedGoals.contains(value)) {
              setState(() {
                _selectedGoals.add(value);
                _customGoalController.clear();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpendingHabitsStep() {
    return _buildStepContent(
      title: 'Spending Habits',
      description: 'How would you describe your spending style?',
      children: _spendingHabits.map((habit) {
        return RadioListTile<String>(
          title: Text(habit, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          subtitle: Text(_getSpendingHabitDescription(habit), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          value: habit,
          groupValue: _spendingHabit,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _spendingHabit = value;
              });
            }
          },
          activeColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  String _getSpendingHabitDescription(String habit) {
    switch (habit) {
      case 'Conservative':
        return 'I carefully plan every expense and save consistently';
      case 'Moderate':
        return 'I balance saving with occasional spending';
      case 'Aggressive':
        return 'I spend freely and focus on enjoying life';
      default:
        return '';
    }
  }

  Widget _buildInvestmentStep() {
    return _buildStepContent(
      title: 'Investment Interest',
      description: 'What\'s your interest level in investments?',
      children: _investmentLevels.map((level) {
        return RadioListTile<String>(
          title: Text(level, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          subtitle: Text(_getInvestmentDescription(level), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          value: level,
          groupValue: _investmentInterest,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _investmentInterest = value;
              });
            }
          },
          activeColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  String _getInvestmentDescription(String level) {
    switch (level) {
      case 'Low':
        return 'I prefer safe savings accounts and fixed deposits';
      case 'Medium':
        return 'I\'m open to balanced mutual funds and some stocks';
      case 'High':
        return 'I actively invest in stocks and mutual funds';
      case 'Very High':
        return 'I\'m an experienced investor open to all options';
      default:
        return '';
    }
  }

  Widget _buildDebtStatusStep() {
    return _buildStepContent(
      title: 'Debt Status',
      description: 'Do you have any outstanding debt?',
      children: [
        ..._debtOptions.map((status) {
          return RadioListTile<String>(
            title: Text(status, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
            value: status,
            groupValue: _debtStatus,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _debtStatus = value;
                });
              }
            },
            activeColor: AppColors.primary,
          );
        }),
        if (_debtStatus == 'Medium' || _debtStatus == 'High')
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: CustomTextField(
              label: 'Total Debt Amount (₹)',
              hint: 'e.g., 500000',
              controller: _debtAmountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.account_balance),
              validator: (value) {
                if (_debtStatus == 'Medium' || _debtStatus == 'High') {
                  if (value == null || value.isEmpty) return 'Required field';
                  if (double.tryParse(value) == null) return 'Must be a number';
                }
                return null;
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmergencyFundStep() {
    return _buildStepContent(
      title: 'Emergency Fund Target',
      description: 'How much should you have for emergencies?',
      children: [
        Text(
          'Financial experts recommend having 3-6 months of expenses as an emergency fund.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Emergency Fund Target (₹)',
          hint: 'e.g., 150000',
          controller: _emergencyFundController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.health_and_safety),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required field';
            if (double.tryParse(value) == null) return 'Must be a number';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Pro Tip',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start small if needed. Even ₹10,000 is better than nothing. Build it up gradually.',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...children,
        ],
      ),
    );
  }
}
