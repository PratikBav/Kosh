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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: achievement.isUnlocked ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
                color: achievement.isUnlocked ? AppColors.primary : AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.title,
              style: AppTextStyles.title.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
