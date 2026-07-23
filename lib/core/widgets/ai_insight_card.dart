import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/text_styles.dart';
import '../models/ai_insight.dart';
import 'glass_card.dart';

class AIInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final InsightType type;
  final DateTime timestamp;
  final bool isRead;
  final VoidCallback? onTap;

  const AIInsightCard({
    super.key,
    required this.title,
    required this.description,
    this.type = InsightType.info,
    required this.timestamp,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GlassCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIcon(),
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.h6.copyWith(
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (!isRead)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case InsightType.success:
        return AppColors.success;
      case InsightType.warning:
        return AppColors.warning;
      case InsightType.danger:
        return AppColors.danger;
      case InsightType.info:
      default:
        return AppColors.primary;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case InsightType.success:
        return Icons.trending_up;
      case InsightType.warning:
        return Icons.warning_amber;
      case InsightType.danger:
        return Icons.trending_down;
      case InsightType.info:
      default:
        return Icons.lightbulb_outline;
    }
  }

  String _formatTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
