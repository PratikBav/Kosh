import 'package:isar/isar.dart';

import '../../../../database/collections/achievement_collection.dart';
import '../../../../database/collections/streak_collection.dart';
import '../../../../database/collections/user_progress_collection.dart';
import '../../../../database/collections/xp_record_collection.dart';

class GamificationRepository {
  GamificationRepository(this._isar);

  final Isar _isar;

  Future<UserProgressCollection> getUserProgress() async {
    final progress = await _isar.userProgressCollections.get(1);
    if (progress == null) {
      throw Exception('User progress not initialized. Ensure IsarService seeded the DB.');
    }
    return progress;
  }

  Future<StreakCollection> getStreak() async {
    final streak = await _isar.streakCollections.get(1);
    if (streak == null) {
      throw Exception('Streak not initialized. Ensure IsarService seeded the DB.');
    }
    return streak;
  }

  Future<List<AchievementCollection>> getAchievements() async {
    return _isar.achievementCollections.where().findAll();
  }

  Future<List<XpRecordCollection>> getRecentXpRecords({int limit = 10}) async {
    return _isar.xpRecordCollections.where().sortByTimestampDesc().limit(limit).findAll();
  }

  /// Expose the raw isar instance for the service to run transactions
  Isar get isar => _isar;
}
