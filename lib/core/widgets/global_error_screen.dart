import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';
import 'custom_button.dart';
import '../../routes/app_routes.dart';

class GlobalErrorScreen extends StatelessWidget {
  final Exception? error;

  const GlobalErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 80,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Oops! Something went wrong.',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                error?.toString() ?? 'We could not find the page you were looking for.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              CustomButton(
                text: 'Return to Dashboard',
                onPressed: () {
                  context.go(RouteNames.dashboard);
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
