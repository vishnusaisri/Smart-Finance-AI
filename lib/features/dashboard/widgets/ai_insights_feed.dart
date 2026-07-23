import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/ai_insight_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/models/ai_insight.dart';

class AIInsightsFeed extends ConsumerWidget {
  const AIInsightsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(aiCoachingProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppStrings.aiInsights,
                    style: AppTextStyles.h5,
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
              TextButton(
                onPressed: () {
                  ref.invalidate(aiCoachingProvider);
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          insightsAsync.when(
            loading: () => const _InsightsLoadingShimmer(),
            error: (error, stack) => _InsightsError(
              error: error,
              onRetry: () => ref.invalidate(aiCoachingProvider),
            ),
            data: (insights) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: insights.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final insight = insights[index];
                return AIInsightCard(
                  title: insight.title,
                  description: insight.description,
                  type: insight.type,
                  timestamp: insight.timestamp,
                  onTap: () {},
                ).animate().slideX(
                  begin: -0.2,
                  end: 0,
                  delay: (index * 100).ms,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ).fadeIn(
                  delay: (index * 100).ms,
                  duration: 300.ms,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsLoadingShimmer extends StatelessWidget {
  const _InsightsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ShimmerLoading(
          width: double.infinity,
          height: 70,
        ),
      )),
    );
  }
}

class _InsightsError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _InsightsError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 32, color: Colors.red),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Failed to load insights',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onRetry,
            child: Text(AppStrings.tryAgain),
          ),
        ],
      ),
    );
  }
}
