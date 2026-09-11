import 'dart:io';

import 'package:isar/isar.dart';
import 'package:kosh/database/collections/achievement_collection.dart';
import 'package:kosh/database/collections/app_settings_collection.dart';
import 'package:kosh/database/collections/contribution_collection.dart';
import 'package:kosh/database/collections/goal_collection.dart';
import 'package:kosh/database/collections/security_settings_collection.dart';
import 'package:kosh/database/collections/streak_collection.dart';
import 'package:kosh/database/collections/transaction_collection.dart';
import 'package:kosh/database/collections/user_progress_collection.dart';
import 'package:kosh/database/collections/vision_item_collection.dart';
import 'package:kosh/database/collections/xp_record_collection.dart';

/// Every schema the app registers, mirroring `IsarService`.
const List<CollectionSchema<dynamic>> testSchemas = [
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

/// A throwaway Isar instance backed by a temp directory.
///
/// Isar has no in-memory mode, so tests that exercise queries, indexes or
/// transactions need a real database on disk.
class TestDatabase {
  TestDatabase._(this.isar, this._directory);

  final Isar isar;
  final Directory _directory;

  /// Downloads the native Isar library once per process. Safe to call
  /// repeatedly.
  static Future<void> ensureInitialized() =>
      Isar.initializeIsarCore(download: true);

  static Future<TestDatabase> open([String name = 'kosh_test']) async {
    final directory = await Directory.systemTemp.createTemp('kosh_test_');
    final isar = await Isar.open(
      testSchemas,
      directory: directory.path,
      name: name,
      inspector: false,
    );
    return TestDatabase._(isar, directory);
  }

  Future<void> close() async {
    await isar.close(deleteFromDisk: true);
    // Windows can still hold a handle briefly after close; the database is
    // already gone, so failing to remove the empty directory is noise.
    try {
      if (_directory.existsSync()) _directory.deleteSync(recursive: true);
    } on FileSystemException {
      // Left for the OS to reap.
    }
  }
}
