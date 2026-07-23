import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../routes/app_routes.dart';
import '../providers/profile_providers.dart';
import '../../auth/services/user_profile_service.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _goalController = TextEditingController();
  String _selectedRisk = 'Medium';

  final List<String> _riskLevels = ['Low', 'Medium', 'High'];
  bool _isLoading = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = FirebaseAuth.instance.currentUser;
      final monthlyIncome = double.tryParse(_incomeController.text) ?? 0.0;
      final savingsGoal = double.tryParse(_goalController.text) ?? 0.0;
      
      if (auth != null) {
        final userProfileService = ref.read(userProfileServiceProvider);
        await userProfileService.createProfileFromAuth(
          auth,
          monthlyIncome: monthlyIncome,
          savingsGoal: savingsGoal,
        );
        final profile = await userProfileService.getUserProfile(auth.uid);
        if (profile != null) {
          await ref.read(userProfileProvider.notifier).updateProfile(profile);
        }
      } else {
        // Mock mode fallback
        final currentProfile = ref.read(userProfileProvider);
        final updated = currentProfile.copyWith(
          monthlyIncome: monthlyIncome,
          savingsGoal: savingsGoal,
        );
        await ref.read(userProfileProvider.notifier).updateProfile(updated);
      }
    } catch (e) {
      debugPrint('Error during profile setup: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go(RouteNames.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Let\'s Personalize Your Experience',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tell us a bit about your finances so we can provide tailored AI insights.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  CustomTextField(
                    label: 'Monthly Income',
                    hint: 'e.g., 5000',
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required field';
                      if (double.tryParse(value) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  CustomTextField(
                    label: 'Target Savings Goal',
                    hint: 'e.g., 1000',
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.savings_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required field';
                      if (double.tryParse(value) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  Text('Risk Tolerance', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _riskLevels.map((risk) {
                      final isSelected = _selectedRisk == risk;
                      return ChoiceChip(
                        label: Text(risk),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRisk = risk);
                          }
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  CustomButton(
                    text: 'Complete Setup',
                    isLoading: _isLoading,
                    onPressed: _handleSetup,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
