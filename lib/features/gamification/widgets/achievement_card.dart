import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../database/collections/achievement_collection.dart';
import '../../../../shared/cards/kosh_card.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.achievement,
  });

  final AchievementCollection achievement;

  @override
  Widget build(BuildContext context) {
    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Opacity(
        opacity: achievement.isUnlocked ? 1.0 : 0.4,
        child: Row(
          children: [
            // Placeholder for icon, in a real app you'd load the Image asset
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achievement.isUnlocked ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
                color: achievement.isUnlocked ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(achievement.description, style: AppTextStyles.body),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: AppTextStyles.label.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
