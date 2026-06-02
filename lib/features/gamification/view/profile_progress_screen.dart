import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../viewmodel/gamification_viewmodel.dart';
import '../widgets/xp_progress_bar.dart';

class ProfileProgressScreen extends ConsumerWidget {
  const ProfileProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    final level = state.progress?.currentLevel ?? 1;
    final xp = state.progress?.totalXp ?? 0;
    final streak = state.streak?.currentStreak ?? 0;
    final longestStreak = state.streak?.longestStreak ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Level Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceLight, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.lg),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Level $level', style: AppTextStyles.displayMedium),
                  Text(state.currentLevelName, style: AppTextStyles.title.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.lg),
                  XpProgressBar(currentXp: xp, targetXp: state.xpToNextLevel, height: 16),
                  const SizedBox(height: AppSpacing.sm),
                  Text('$xp / ${state.xpToNextLevel} XP', style: AppTextStyles.label),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),

            // Streaks
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.danger,
                    title: 'Current Streak',
                    value: '$streak Days',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.whatshot,
                    iconColor: AppColors.warning,
                    title: 'Longest Streak',
                    value: '$longestStreak Days',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Achievements Button
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(RouteConstants.achievements),
              icon: const Icon(Icons.emoji_events),
              label: Text('View Achievements (${state.unlockedAchievements.length})'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
