import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/profile_providers.dart';

class PersonalInfoForm extends ConsumerWidget {
  const PersonalInfoForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTextStyles.h5),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
            initialValue: userProfile.fullName,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            initialValue: userProfile.email,
            enabled: false,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
            initialValue: '',
          ),
        ],
      ),
    );
  }
}
