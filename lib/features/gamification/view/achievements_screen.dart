import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../viewmodel/gamification_viewmodel.dart';
import '../widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Achievements'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Unlocked'),
              Tab(text: 'Locked'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Unlocked Tab
            state.unlockedAchievements.isEmpty
                ? const Center(child: Text('No achievements unlocked yet.\nStart logging transactions!'))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.unlockedAchievements.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return AchievementCard(achievement: state.unlockedAchievements[index]);
                    },
                  ),
            
            // Locked Tab
            state.lockedAchievements.isEmpty
                ? const Center(child: Text('You unlocked everything!'))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.lockedAchievements.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return AchievementCard(achievement: state.lockedAchievements[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
