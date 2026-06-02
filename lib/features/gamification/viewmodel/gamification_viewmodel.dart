import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/collections/achievement_collection.dart';
import '../../../../database/collections/streak_collection.dart';
import '../../../../database/collections/user_progress_collection.dart';

import '../../../../core/services/gamification_service.dart';
import '../../../../providers/repository_providers.dart';
import '../repository/gamification_repository.dart';
import 'gamification_state.dart';

final gamificationViewModelProvider = StateNotifierProvider<GamificationViewModel, GamificationState>((ref) {
  final repo = ref.watch(gamificationRepositoryProvider);
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  final service = GamificationService(gamificationRepository: repo, analyticsRepository: analyticsRepo);
  return GamificationViewModel(repo, service);
});

class GamificationViewModel extends StateNotifier<GamificationState> {
  GamificationViewModel(this._repository, this._service) : super(const GamificationState()) {
    _init();
  }

  final GamificationRepository _repository;
  final GamificationService _service;
  
  StreamSubscription<void>? _progressSub;
  StreamSubscription<void>? _streakSub;
  StreamSubscription<void>? _achievementSub;

  void _init() {
    loadGamificationData();
    _setupWatchers();
  }

  void _setupWatchers() {
    final isar = _repository.isar;
    _progressSub = isar.userProgressCollections.watchLazy().listen((_) => loadGamificationData());
    _streakSub = isar.streakCollections.watchLazy().listen((_) => loadGamificationData());
    _achievementSub = isar.achievementCollections.watchLazy().listen((_) => loadGamificationData());
  }

  Future<void> loadGamificationData() async {
    try {
      final progress = await _repository.getUserProgress();
      final streak = await _repository.getStreak();
      final allAchievements = await _repository.getAchievements();

      final unlocked = allAchievements.where((a) => a.isUnlocked).toList();
      final locked = allAchievements.where((a) => !a.isUnlocked).toList();

      final xpToNext = GamificationService.getXpForNextLevel(progress.currentLevel);
      final levelName = GamificationService.getLevelName(progress.currentLevel);

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          progress: progress,
          streak: streak,
          unlockedAchievements: unlocked,
          lockedAchievements: locked,
          xpToNextLevel: xpToNext,
          currentLevelName: levelName,
          error: null,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  // --- Triggers called from other modules ---

  Future<void> logTransactionActivity() async {
    // 1. Award XP
    await _service.awardXP(5, 'Logged a transaction');
    
    // 2. Update Streak
    await _service.updateStreak();
    
    // Note: checkMilestones() is called internally by awardXP() in GamificationService
  }

  Future<void> logGoalCreated() async {
    await _service.awardXP(20, 'Created a new goal');
    await _service.updateStreak();
    await _service.unlockAchievement('goal_setter');
  }

  Future<void> logGoalContribution() async {
    await _service.awardXP(10, 'Contributed to a goal');
    await _service.updateStreak();
  }

  Future<void> logGoalCompleted() async {
    await _service.awardXP(100, 'Goal Completed!');
    await _service.updateStreak();
    await _service.unlockAchievement('goal_crusher');
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    _streakSub?.cancel();
    _achievementSub?.cancel();
    super.dispose();
  }
}
