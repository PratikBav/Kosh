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

  static Future<void> _seedDatabase(Isar isar) async {
    final settings = await isar.appSettingsCollections.get(1);
    
    if (settings == null || !settings.isAchievementSeeded) {
      await isar.writeTxn(() async {
        // Create settings
        final newSettings = AppSettingsCollection()
          ..id = 1
          ..isAchievementSeeded = true
          ..appVersion = '1.0.0';
        await isar.appSettingsCollections.put(newSettings);

        // Create default user progress
        final progress = UserProgressCollection()
          ..id = 1
          ..totalXp = 0
          ..currentLevel = 1;
        await isar.userProgressCollections.put(progress);

        // Create default streak
        final streak = StreakCollection()
          ..id = 1
          ..currentStreak = 0
          ..longestStreak = 0;
        await isar.streakCollections.put(streak);

        // Seed Achievements
        final achievements = [
          AchievementCollection()..key = 'first_step'..title = 'First Step'..description = 'Add your first transaction'..icon = 'assets/icons/achievements/first_step.png'..xpReward = 50,
          AchievementCollection()..key = 'goal_setter'..title = 'Goal Setter'..description = 'Create your first goal'..icon = 'assets/icons/achievements/goal_setter.png'..xpReward = 100,
          AchievementCollection()..key = 'consistent_saver'..title = 'Consistent Saver'..description = 'Maintain a 7-day streak'..icon = 'assets/icons/achievements/consistent_saver.png'..xpReward = 200,
          AchievementCollection()..key = 'goal_crusher'..title = 'Goal Crusher'..description = 'Complete your first goal'..icon = 'assets/icons/achievements/goal_crusher.png'..xpReward = 500,
          AchievementCollection()..key = 'wealth_builder'..title = 'Wealth Builder'..description = 'Save ₹10,000'..icon = 'assets/icons/achievements/wealth_builder.png'..xpReward = 1000,
          AchievementCollection()..key = 'financial_warrior'..title = 'Financial Warrior'..description = 'Save ₹50,000'..icon = 'assets/icons/achievements/financial_warrior.png'..xpReward = 2000,
          AchievementCollection()..key = 'century_club'..title = 'Century Club'..description = 'Record 100 transactions'..icon = 'assets/icons/achievements/century_club.png'..xpReward = 1500,
          AchievementCollection()..key = 'financial_master'..title = 'Financial Master'..description = 'Reach Level 8'..icon = 'assets/icons/achievements/financial_master.png'..xpReward = 5000,
        ];
        
        await isar.achievementCollections.putAll(achievements);
      });
    }
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
