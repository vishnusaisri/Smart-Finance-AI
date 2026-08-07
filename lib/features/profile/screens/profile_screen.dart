import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/toast_overlay.dart';
import '../../auth/controllers/auth_controller.dart';
import '../providers/profile_providers.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditIncomeDialog(BuildContext context, WidgetRef ref, double currentIncome, double currentGoal) {
    final controller = TextEditingController(text: currentIncome > 0 ? currentIncome.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit Monthly Income', style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter amount (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newIncome = double.tryParse(controller.text) ?? 0.0;
              ref.read(userProfileProvider.notifier).updateFinancialGoals(
                monthlyIncome: newIncome,
                savingsGoal: currentGoal,
              );
              ref.showSuccessToast('Monthly Income updated to ₹${newIncome.toStringAsFixed(0)}');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSavingsGoalDialog(BuildContext context, WidgetRef ref, double currentIncome, double currentGoal) {
    final controller = TextEditingController(text: currentGoal > 0 ? currentGoal.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit Savings Goal', style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter monthly savings goal (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = double.tryParse(controller.text) ?? 0.0;
              ref.read(userProfileProvider.notifier).updateFinancialGoals(
                monthlyIncome: currentIncome,
                savingsGoal: newGoal,
              );
              ref.showSuccessToast('Savings Goal updated to ₹${newGoal.toStringAsFixed(0)}');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final initial = userProfile.fullName.isNotEmpty ? userProfile.fullName[0].toUpperCase() : 'U';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Profile Settings', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xl),
            
            // User Info Card
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.fullName.isNotEmpty ? userProfile.fullName : 'Smart Finance User',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile.email.isNotEmpty ? userProfile.email : 'user@smartfinance.ai',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Preferences
            Text('Preferences', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
                      title: const Text('Currency'),
                      trailing: Text(userProfile.currency, style: const TextStyle(color: AppColors.textSecondary)),
                      onTap: () {},
                    ),
                  ),
                  const Divider(height: 1),
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.language_outlined, color: AppColors.primary),
                      title: const Text('Locale'),
                      trailing: Text(userProfile.locale, style: const TextStyle(color: AppColors.textSecondary)),
                      onTap: () {},
                    ),
                  ),
                  const Divider(height: 1),
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                      title: const Text('Push Notifications'),
                      value: userProfile.notificationsEnabled,
                      onChanged: (val) {
                        ref.read(userProfileProvider.notifier).updateNotifications(
                          notificationsEnabled: val,
                          budgetAlertsEnabled: userProfile.budgetAlertsEnabled,
                          spendingLimitAlerts: userProfile.spendingLimitAlerts,
                          lowBalanceAlerts: userProfile.lowBalanceAlerts,
                          weeklyReports: userProfile.weeklyReports,
                          monthlyReports: userProfile.monthlyReports,
                        );
                        ref.showSuccessToast(val ? 'Notifications enabled' : 'Notifications disabled');
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 1),
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      secondary: const Icon(Icons.nightlight_outlined, color: AppColors.primary),
                      title: const Text('Dark Mode'),
                      value: userProfile.darkMode,
                      onChanged: (val) {
                        ref.read(userProfileProvider.notifier).toggleDarkMode(val);
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Financial Goals
            Text('Financial Settings', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success),
                      title: const Text('Monthly Income'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${userProfile.monthlyIncome.toStringAsFixed(0)}',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.success),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined, size: 18),
                        ],
                      ),
                      onTap: () => _showEditIncomeDialog(context, ref, userProfile.monthlyIncome, userProfile.savingsGoal),
                    ),
                  ),
                  const Divider(height: 1),
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.savings_outlined, color: AppColors.accent),
                      title: const Text('Savings Goal'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${userProfile.savingsGoal.toStringAsFixed(0)}',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined, size: 18),
                        ],
                      ),
                      onTap: () => _showEditSavingsGoalDialog(context, ref, userProfile.monthlyIncome, userProfile.savingsGoal),
                    ),
                  ),
                  const Divider(height: 1),
                  Card(
                    color: const Color(0x0A1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.analytics_outlined, color: AppColors.secondary),
                      title: const Text('Risk Profile'),
                      trailing: const Text('Moderate', style: TextStyle(color: AppColors.textSecondary)),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Logout Button
            CustomButton(
              text: 'Log Out',
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
                context.go(RouteNames.login);
              },
              fullWidth: true,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
