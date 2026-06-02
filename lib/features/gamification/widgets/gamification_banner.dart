import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../viewmodel/gamification_state.dart';
import 'xp_progress_bar.dart';

class GamificationBanner extends StatelessWidget {
  const GamificationBanner({
    super.key,
    required this.state,
  });

  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
    }

    final level = state.progress?.currentLevel ?? 1;
    final xp = state.progress?.totalXp ?? 0;
    final targetXp = state.xpToNextLevel;
    final streak = state.streak?.currentStreak ?? 0;

    return GestureDetector(
      onTap: () {
        context.pushNamed(RouteConstants.profileProgress);
      },
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Level $level • ${state.currentLevelName}',
                      style: AppTextStyles.title,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.danger, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$streak Day Streak',
                      style: AppTextStyles.label.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            XpProgressBar(currentXp: xp, targetXp: targetXp),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$xp / $targetXp XP',
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'Tap to view profile',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
