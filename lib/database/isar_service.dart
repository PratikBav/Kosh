import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import 'collections/transaction_collection.dart';
import 'collections/goal_collection.dart';
import 'collections/contribution_collection.dart';
import 'collections/achievement_collection.dart';
import 'collections/xp_record_collection.dart';
import 'collections/streak_collection.dart';
import 'collections/user_progress_collection.dart';
import 'collections/app_settings_collection.dart';
import 'collections/security_settings_collection.dart';
import 'collections/vision_item_collection.dart';

/// Manages the Isar database lifecycle.
///
/// Call [initialize] once at app startup before accessing [instance].
/// Future collections (Expense, Income, Goal, etc.) will be registered
/// in the [_schemas] list when their models are created.
class IsarService {
  IsarService._();

  static Isar? _isar;

  /// The active Isar database instance.
  ///
  /// Throws [StateError] if accessed before [initialize].
  static Isar get instance {
    if (_isar == null) {
      throw StateError(
        'IsarService not initialized. Call IsarService.initialize() first.',
      );
    }
    return _isar!;
  }

  /// Whether the database has been initialized.
  static bool get isInitialized => _isar != null;

  /// Opens the Isar database with all registered collection schemas.
  ///
  /// Should be called once in `main()` before `runApp()`.
  static Future<void> initialize() async {
    if (_isar != null) return; // already initialized

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      _schemas,
      directory: dir.path,
      name: AppConstants.databaseName,
      inspector: false, // disable inspector in production
    );

    await _seedDatabase(_isar!);
  }

  /// The achievement catalogue. Each icon resolves to
  /// `assets/icons/achievements/<key>.png`.
  ///
  /// Adding an entry here is enough to ship a new achievement — [_seedDatabase]
  /// inserts only the keys that are missing.
  static const List<
      ({
        String key,
        String title,
        String description,
        int xpReward,
      })> _achievementSeeds = [
    (
      key: 'first_step',
      title: 'First Step',
      description: 'Add your first transaction',
      xpReward: 50,
    ),
    (
      key: 'goal_setter',
      title: 'Goal Setter',
      description: 'Create your first goal',
      xpReward: 100,
    ),
    (
      key: 'consistent_saver',
      title: 'Consistent Saver',
      description: 'Maintain a 7-day streak',
      xpReward: 200,
    ),
    (
      key: 'goal_crusher',
      title: 'Goal Crusher',
      description: 'Complete your first goal',
      xpReward: 500,
    ),
    (
      key: 'wealth_builder',
      title: 'Wealth Builder',
      description: 'Save ₹10,000',
      xpReward: 1000,
    ),
    (
      key: 'financial_warrior',
      title: 'Financial Warrior',
      description: 'Save ₹50,000',
      xpReward: 2000,
    ),
    (
      key: 'century_club',
      title: 'Century Club',
      description: 'Record 100 transactions',
      xpReward: 1500,
    ),
    (
      key: 'financial_master',
      title: 'Financial Master',
      description: 'Reach Level 8',
      xpReward: 5000,
    ),
  ];

  /// Ensures the singleton rows and the achievement catalogue exist.
  ///
  /// Idempotent by construction: it inserts only what is actually missing
  /// rather than trusting a flag. `key` carries a unique index, so a seed that
  /// re-ran would throw and leave the app unable to open the database.
  static Future<void> _seedDatabase(Isar isar) async {
    final settings = await isar.appSettingsCollections.get(1);
    final progress = await isar.userProgressCollections.get(1);
    final streak = await isar.streakCollections.get(1);

    final existingKeys = (await isar.achievementCollections.where().findAll())
        .map((achievement) => achievement.key)
        .toSet();
    final missingAchievements = _achievementSeeds
        .where((seed) => !existingKeys.contains(seed.key))
        .toList();

    final isComplete = settings != null &&
        progress != null &&
        streak != null &&
        missingAchievements.isEmpty;
    if (isComplete) return;

    await isar.writeTxn(() async {
      if (settings == null) {
        await isar.appSettingsCollections.put(
          AppSettingsCollection()
            ..id = 1
            ..isAchievementSeeded = true
            ..appVersion = '1.0.0',
        );
      }

      if (progress == null) {
        await isar.userProgressCollections.put(
          UserProgressCollection()
            ..id = 1
            ..totalXp = 0
            ..currentLevel = 1,
        );
      }

      if (streak == null) {
        await isar.streakCollections.put(
          StreakCollection()
            ..id = 1
            ..currentStreak = 0
            ..longestStreak = 0,
        );
      }

      if (missingAchievements.isNotEmpty) {
        await isar.achievementCollections.putAll([
          for (final seed in missingAchievements)
            AchievementCollection()
              ..key = seed.key
              ..title = seed.title
              ..description = seed.description
              ..icon = 'assets/icons/achievements/${seed.key}.png'
              ..xpReward = seed.xpReward,
        ]);
      }
    });
  }

  /// Collection schemas to register.
  static final List<CollectionSchema<dynamic>> _schemas = [
    TransactionCollectionSchema,
    GoalCollectionSchema,
    ContributionCollectionSchema,
    AchievementCollectionSchema,
    XpRecordCollectionSchema,
    StreakCollectionSchema,
    UserProgressCollectionSchema,
    AppSettingsCollectionSchema,
    SecuritySettingsCollectionSchema,
    VisionItemCollectionSchema,
  ];

  /// Closes the database connection.
  ///
  /// Typically called when the app is disposed.
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Clears all data from the database.
  ///
  /// Use with caution — this is destructive.
  static Future<void> clearAll() async {
    await _isar?.writeTxn(() async {
      await _isar!.clear();
    });
  }
}
