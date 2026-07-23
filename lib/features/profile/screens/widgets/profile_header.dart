import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/profile_providers.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: userProfile.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      userProfile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 40, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userProfile.fullName, style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.sm),
                Text(userProfile.email, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Member since ${userProfile.createdAt.month} ${userProfile.createdAt.year}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
