import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/cards/kosh_card.dart';
import '../../gamification/viewmodel/gamification_state.dart';

class StreakProgressCard extends StatelessWidget {
  final GamificationState gamificationState;

  const StreakProgressCard({super.key, required this.gamificationState});

  @override
  Widget build(BuildContext context) {
    if (gamificationState.isLoading) {
      return const SizedBox(height: 100);
    }
    
    final streak = gamificationState.streak?.currentStreak ?? 0;
    final progress = gamificationState.progress;
    final totalXp = progress?.totalXp ?? 0;
    
    if (progress == null) return const SizedBox.shrink();

    final nextLevelXp = gamificationState.xpToNextLevel;
    final xpProgress = nextLevelXp > 0 ? (totalXp / nextLevelXp).clamp(0.0, 1.0) : 0.0;
    final level = progress.currentLevel;

    return KoshCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$streak Day Streak',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Level $level',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${totalXp}XP / ${nextLevelXp}XP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
