import 'package:isar/isar.dart';

import '../../database/collections/achievement_collection.dart';
import '../../database/collections/streak_collection.dart';
import '../../database/collections/user_progress_collection.dart';
import '../../database/collections/xp_record_collection.dart';
import '../../database/collections/transaction_collection.dart';
import '../../features/analytics/repository/analytics_repository.dart';
import '../../features/gamification/repository/gamification_repository.dart';

class GamificationService {
  GamificationService({
    required this.gamificationRepository,
    required this.analyticsRepository,
  });

  final GamificationRepository gamificationRepository;
  final AnalyticsRepository analyticsRepository;

  static const List<int> _levelThresholds = [
    0,      // Level 1
    100,    // Level 2
    250,    // Level 3
    500,    // Level 4
    1000,   // Level 5
    2000,   // Level 6
    3500,   // Level 7
    5000,   // Level 8
  ];

  static String getLevelName(int level) {
    switch (level) {
      case 1: return 'Beginner';
      case 2: return 'Saver';
      case 3: return 'Planner';
      case 4: return 'Builder';
      case 5: return 'Wealth Seeker';
      case 6: return 'Investor';
      case 7: return 'Strategist';
      case 8: return 'Financial Master';
      default: return 'Financial Master';
    }
  }

  static int getXpForNextLevel(int currentLevel) {
    if (currentLevel >= _levelThresholds.length) return _levelThresholds.last;
    return _levelThresholds[currentLevel];
  }

  Future<void> awardXP(int amount, String reason) async {
    final isar = gamificationRepository.isar;
    await isar.writeTxn(() async {
      // 1. Record XP
      final record = XpRecordCollection()
        ..amount = amount
        ..reason = reason
        ..timestamp = DateTime.now();
      await isar.xpRecordCollections.put(record);

      // 2. Update Total XP
      final progress = await isar.userProgressCollections.get(1);
      if (progress != null) {
        progress.totalXp += amount;
        
        // 3. Calculate Level
        int newLevel = 1;
        for (int i = 0; i < _levelThresholds.length; i++) {
          if (progress.totalXp >= _levelThresholds[i]) {
            newLevel = i + 1;
          } else {
            break;
          }
        }
        
        progress.currentLevel = newLevel;
        await isar.userProgressCollections.put(progress);
      }
    });

    await checkMilestones();
  }

  Future<void> updateStreak() async {
    final isar = gamificationRepository.isar;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    await isar.writeTxn(() async {
      final streak = await isar.streakCollections.get(1);
      if (streak == null) return;

      if (streak.lastActivityDate != null) {
        final last = streak.lastActivityDate!;
        final lastDay = DateTime(last.year, last.month, last.day);
        
        final diff = today.difference(lastDay).inDays;
        
        if (diff == 0) {
          // Already logged activity today, do nothing
          return;
        } else if (diff == 1) {
          // Next day activity, increment streak
          streak.currentStreak += 1;
        } else {
          // Missed a day or more, reset streak
          streak.currentStreak = 1;
        }
      } else {
        // First activity ever
        streak.currentStreak = 1;
      }
      
      streak.lastActivityDate = now;
      if (streak.currentStreak > streak.longestStreak) {
        streak.longestStreak = streak.currentStreak;
      }
      
      await isar.streakCollections.put(streak);
    });

    await _checkStreakAchievements();
  }

  Future<void> _checkStreakAchievements() async {
    final streak = await gamificationRepository.getStreak();
    if (streak.currentStreak >= 7) {
      await unlockAchievement('consistent_saver');
    }
  }

  Future<void> unlockAchievement(String key) async {
    final isar = gamificationRepository.isar;
    final achievement = await isar.achievementCollections.where().keyEqualTo(key).findFirst();
    
    if (achievement != null && !achievement.isUnlocked) {
      await isar.writeTxn(() async {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
        await isar.achievementCollections.put(achievement);
      });
      // Award XP for the achievement
      await awardXP(achievement.xpReward, 'Achievement Unlocked: ${achievement.title}');
    }
  }

  Future<void> checkMilestones() async {
    final start = DateTime(1970);
    final end = DateTime.now();
    final overall = await analyticsRepository.getOverallSummary(start, end);
    final totalSavings = overall['savings'] ?? 0;

    if (totalSavings >= 10000) {
      await unlockAchievement('wealth_builder');
    }
    if (totalSavings >= 50000) {
      await unlockAchievement('financial_warrior');
    }

    final isar = gamificationRepository.isar;
    final txCount = await isar.transactionCollections.count();
    if (txCount >= 100) {
      await unlockAchievement('century_club');
    }
    
    final progress = await isar.userProgressCollections.get(1);
    if (progress != null && progress.currentLevel >= 8) {
      await unlockAchievement('financial_master');
    }
  }
}
