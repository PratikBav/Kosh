import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';

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
  }

  /// Collection schemas to register.
  ///
  /// Add new collection schemas here as features are built:
  /// ```dart
  /// static final List<CollectionSchema<dynamic>> _schemas = [
  ///   ExpenseSchema,
  ///   IncomeSchema,
  ///   GoalSchema,
  ///   GoalContributionSchema,
  ///   InvestmentSchema,
  ///   AchievementSchema,
  ///   SettingsSchema,
  /// ];
  /// ```
  static final List<CollectionSchema<dynamic>> _schemas = [
    // Collections will be added here as models are created.
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
