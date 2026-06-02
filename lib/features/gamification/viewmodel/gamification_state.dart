import '../../../../database/collections/achievement_collection.dart';
import '../../../../database/collections/streak_collection.dart';
import '../../../../database/collections/user_progress_collection.dart';

class GamificationState {
  const GamificationState({
    this.isLoading = true,
    this.progress,
    this.streak,
    this.unlockedAchievements = const [],
    this.lockedAchievements = const [],
    this.xpToNextLevel = 100,
    this.currentLevelName = 'Beginner',
    this.error,
  });

  final bool isLoading;
  final UserProgressCollection? progress;
  final StreakCollection? streak;
  final List<AchievementCollection> unlockedAchievements;
  final List<AchievementCollection> lockedAchievements;
  final int xpToNextLevel;
  final String currentLevelName;
  final String? error;

  GamificationState copyWith({
    bool? isLoading,
    UserProgressCollection? progress,
    StreakCollection? streak,
    List<AchievementCollection>? unlockedAchievements,
    List<AchievementCollection>? lockedAchievements,
    int? xpToNextLevel,
    String? currentLevelName,
    String? error,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      lockedAchievements: lockedAchievements ?? this.lockedAchievements,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      currentLevelName: currentLevelName ?? this.currentLevelName,
      error: error,
    );
  }
}
