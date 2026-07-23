import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User Name', style: AppTextStyles.h3),
                          Text('user@example.com', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
                      trailing: const Text('INR (₹)', style: TextStyle(color: AppColors.textSecondary)),
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
                      trailing: const Text('en-US', style: TextStyle(color: AppColors.textSecondary)),
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
                      value: true,
                      onChanged: (val) {},
                      activeColor: AppColors.primary,
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
                      value: true,
                      onChanged: (val) {},
                      activeColor: AppColors.primary,
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
                      trailing: const Icon(Icons.chevron_right),
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
                      leading: const Icon(Icons.savings_outlined, color: AppColors.accent),
                      title: const Text('Savings Goal'),
                      trailing: const Icon(Icons.chevron_right),
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
                      leading: const Icon(Icons.analytics_outlined, color: AppColors.secondary),
                      title: const Text('Risk Profile'),
                      trailing: const Icon(Icons.chevron_right),
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
