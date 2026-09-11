import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../../database/collections/achievement_collection.dart';
import '../../database/collections/app_settings_collection.dart';
import '../../database/collections/contribution_collection.dart';
import '../../database/collections/goal_collection.dart';
import '../../database/collections/streak_collection.dart';
import '../../database/collections/transaction_collection.dart';
import '../../database/collections/user_progress_collection.dart';
import '../../database/collections/vision_item_collection.dart';
import '../../database/collections/xp_record_collection.dart';
import '../../features/goals/models/goal_category.dart';
import '../../features/goals/models/goal_priority.dart';
import '../../features/transactions/models/transaction_category.dart';
import '../../features/transactions/models/transaction_type.dart';
import '../errors/app_exception.dart';

/// Summary of what a restore actually wrote, so the UI can report the outcome
/// instead of claiming a blanket success.
class BackupRestoreResult {
  const BackupRestoreResult({
    required this.transactions,
    required this.goals,
    required this.contributions,
    required this.visionItems,
    required this.achievementsUnlocked,
    required this.skipped,
  });

  final int transactions;
  final int goals;
  final int contributions;
  final int visionItems;
  final int achievementsUnlocked;

  /// Human-readable notes about records that could not be restored.
  final List<String> skipped;

  int get totalRecords => transactions + goals + contributions + visionItems;

  bool get hasSkipped => skipped.isNotEmpty;
}

/// Handles full-database export and restore, plus CSV reporting.
///
/// Backups are versioned. Version 2 adds contribution history, gamification
/// progress and position-based goal cross-references; version 1 backups are
/// still accepted so older files keep restoring.
class BackupService {
  BackupService(this.isar);

  final Isar isar;

  /// Version written by [exportBackup].
  static const int currentSchemaVersion = 2;

  /// Versions [importBackup] knows how to read.
  static const List<int> supportedSchemaVersions = [1, 2];

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  /// Writes a full JSON backup to a user-chosen location.
  ///
  /// Returns the file path, or `null` if the user cancelled the save dialog.
  Future<String?> exportBackup() async {
    try {
      final payload = await buildBackupPayload();
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Backup',
        fileName: 'kosh_backup_$formattedDate.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile == null) return null;

      await File(outputFile).writeAsString(jsonString);
      return outputFile;
    } on AppException {
      rethrow;
    } catch (e, stack) {
      throw StorageException(
        message: 'Could not write the backup file. $e',
        stackTrace: stack,
      );
    }
  }

  /// Builds the complete backup payload from the database.
  ///
  /// Separated from [exportBackup] so the serialization can be exercised
  /// without going through a file picker.
  Future<Map<String, dynamic>> buildBackupPayload() async {
    final transactions = await isar.transactionCollections.where().findAll();
    final goals = await isar.goalCollections.where().findAll();
    final contributions = await isar.contributionCollections.where().findAll();
    final visions = await isar.visionItemCollections.where().findAll();
    final achievements = await isar.achievementCollections.where().findAll();
    final xpRecords = await isar.xpRecordCollections.where().findAll();
    final progress = await isar.userProgressCollections.get(1);
    final streak = await isar.streakCollections.get(1);
    final settings = await isar.appSettingsCollections.get(1);

    // Goals are referenced by their position in the exported list, never by
    // their Isar id — ids are reassigned when rows are re-inserted on restore,
    // which is what used to re-point contributions at the wrong goal.
    final goalRefById = <int, int>{
      for (var i = 0; i < goals.length; i++) goals[i].id: i,
    };

    return {
      'version': currentSchemaVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': [
        for (final t in transactions)
          {
            'title': t.title,
            'amount': t.amount,
            'type': t.type.name,
            'category': t.category.name,
            'date': t.date.toIso8601String(),
            'notes': t.notes,
            'createdAt': t.createdAt.toIso8601String(),
            'updatedAt': t.updatedAt.toIso8601String(),
          },
      ],
      'goals': [
        for (var i = 0; i < goals.length; i++)
          {
            'ref': i,
            'title': goals[i].title,
            'description': goals[i].description,
            'targetAmount': goals[i].targetAmount,
            'currentAmount': goals[i].currentAmount,
            'deadline': goals[i].deadline.toIso8601String(),
            'priority': goals[i].priority.name,
            'category': goals[i].category.name,
            'isCompleted': goals[i].isCompleted,
            'createdAt': goals[i].createdAt.toIso8601String(),
            'updatedAt': goals[i].updatedAt.toIso8601String(),
          },
      ],
      'contributions': [
        for (final c in contributions)
          if (goalRefById.containsKey(c.goalId))
            {
              'goalRef': goalRefById[c.goalId],
              'amount': c.amount,
              'note': c.note,
              'date': c.date.toIso8601String(),
              'createdAt': c.createdAt.toIso8601String(),
            },
      ],
      'visions': [
        for (final v in visions)
          {
            'title': v.title,
            'description': v.description,
            'imagePath': v.imagePath,
            'quote': v.quote,
            'goalRef': v.goalId == null ? null : goalRefById[v.goalId],
            'category': v.category.name,
            'isPinned': v.isPinned,
            'createdAt': v.createdAt.toIso8601String(),
            'updatedAt': v.updatedAt.toIso8601String(),
          },
      ],
      'gamification': {
        'totalXp': progress?.totalXp ?? 0,
        'currentLevel': progress?.currentLevel ?? 1,
        'currentStreak': streak?.currentStreak ?? 0,
        'longestStreak': streak?.longestStreak ?? 0,
        'lastActivityDate': streak?.lastActivityDate?.toIso8601String(),
        'unlockedAchievements': [
          for (final a in achievements)
            if (a.isUnlocked)
              {
                'key': a.key,
                'unlockedAt': a.unlockedAt?.toIso8601String(),
              },
        ],
        'xpRecords': [
          for (final r in xpRecords)
            {
              'amount': r.amount,
              'reason': r.reason,
              'timestamp': r.timestamp.toIso8601String(),
            },
        ],
      },
      'appearance': {
        'accentColorIndex': settings?.accentColorIndex,
        'customAccentColorValue': settings?.customAccentColorValue,
      },
    };
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Replaces all local data with the contents of a user-chosen backup file.
  ///
  /// Returns `null` if the user cancelled the file picker. Throws an
  /// [AppException] if the file is unreadable or not a supported backup;
  /// nothing is written unless the file is accepted.
  Future<BackupRestoreResult?> importBackup() async {
    final Map<String, dynamic> data;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      final path = result?.files.single.path;
      if (path == null) return null;

      final decoded = jsonDecode(await File(path).readAsString());
      if (decoded is! Map<String, dynamic>) {
        throw const ValidationException(
          message: 'That file is not a Kosh backup.',
        );
      }
      data = decoded;
    } on AppException {
      rethrow;
    } on FormatException {
      throw const ValidationException(
        message: 'That file is not valid JSON and cannot be restored.',
      );
    } catch (e, stack) {
      throw StorageException(
        message: 'Could not read the backup file. $e',
        stackTrace: stack,
      );
    }

    return restoreFromBackup(data);
  }

  /// Validates and restores an already-decoded backup payload.
  ///
  /// Separated from [importBackup] so the restore logic can be exercised
  /// without going through a file picker.
  Future<BackupRestoreResult> restoreFromBackup(
    Map<String, dynamic> data,
  ) async {
    final version = _asInt(data['version']);
    if (version == null || !supportedSchemaVersions.contains(version)) {
      throw ValidationException(
        message: 'Unsupported backup version. '
            'This app reads versions ${supportedSchemaVersions.join(', ')}.',
      );
    }

    return _restore(data, version);
  }

  Future<BackupRestoreResult> _restore(
    Map<String, dynamic> data,
    int version,
  ) async {
    final skipped = <String>[];
    var restoredTransactions = 0;
    var restoredGoals = 0;
    var restoredContributions = 0;
    var restoredVisions = 0;
    var unlockedAchievements = 0;

    try {
      await isar.writeTxn(() async {
        await isar.transactionCollections.clear();
        await isar.goalCollections.clear();
        // Cleared alongside goals: leaving these behind is what let stale
        // contributions re-attach themselves to unrelated restored goals.
        await isar.contributionCollections.clear();
        await isar.visionItemCollections.clear();
        await isar.xpRecordCollections.clear();

        // --- Transactions ---
        var droppedTransactions = 0;
        final transactions = <TransactionCollection>[];
        for (final raw in _asList(data['transactions'])) {
          final title = _asString(raw['title']);
          final amount = _asDouble(raw['amount']);
          final date = _asDate(raw['date']);
          final type = _enumByName(TransactionType.values, raw['type']);
          final category =
              _enumByName(TransactionCategory.values, raw['category']);

          if (title == null ||
              amount == null ||
              date == null ||
              type == null ||
              category == null) {
            droppedTransactions++;
            continue;
          }

          transactions.add(
            TransactionCollection()
              ..title = title
              ..amount = amount
              ..type = type
              ..category = category
              ..date = date
              ..notes = _asString(raw['notes'])
              ..createdAt = _asDate(raw['createdAt']) ?? date
              ..updatedAt = _asDate(raw['updatedAt']) ?? date,
          );
        }
        await isar.transactionCollections.putAll(transactions);
        restoredTransactions = transactions.length;
        if (droppedTransactions > 0) {
          skipped.add('$droppedTransactions transaction(s) were malformed');
        }

        // --- Goals ---
        // refOrder tracks each restored goal's reference from the backup so it
        // can be paired with the id Isar assigns, letting child records be
        // re-pointed accurately.
        var droppedGoals = 0;
        final goals = <GoalCollection>[];
        final refOrder = <int>[];

        final rawGoals = _asList(data['goals']);
        for (var i = 0; i < rawGoals.length; i++) {
          final raw = rawGoals[i];
          final title = _asString(raw['title']);
          final target = _asDouble(raw['targetAmount']);
          final deadline = _asDate(raw['deadline']);
          final priority = _enumByName(GoalPriority.values, raw['priority']);
          final category = _enumByName(GoalCategory.values, raw['category']);

          if (title == null ||
              target == null ||
              deadline == null ||
              priority == null ||
              category == null) {
            droppedGoals++;
            continue;
          }

          // Version 1 files have no 'ref'; fall back to list position.
          refOrder.add(_asInt(raw['ref']) ?? i);
          goals.add(
            GoalCollection()
              ..title = title
              ..description = _asString(raw['description'])
              ..targetAmount = target
              ..currentAmount = _asDouble(raw['currentAmount']) ?? 0
              ..deadline = deadline
              ..priority = priority
              ..category = category
              ..isCompleted = _asBool(raw['isCompleted']) ?? false
              ..createdAt = _asDate(raw['createdAt']) ?? DateTime.now()
              ..updatedAt = _asDate(raw['updatedAt']) ?? DateTime.now(),
          );
        }

        final newGoalIds = await isar.goalCollections.putAll(goals);
        restoredGoals = goals.length;
        final newGoalIdByRef = <int, int>{
          for (var i = 0; i < refOrder.length; i++) refOrder[i]: newGoalIds[i],
        };
        if (droppedGoals > 0) {
          skipped.add('$droppedGoals goal(s) were malformed');
        }

        // --- Contributions (version 2+) ---
        var orphanedContributions = 0;
        final contributions = <ContributionCollection>[];
        for (final raw in _asList(data['contributions'])) {
          final goalId = newGoalIdByRef[_asInt(raw['goalRef'])];
          final amount = _asDouble(raw['amount']);
          final date = _asDate(raw['date']);

          if (goalId == null || amount == null || date == null) {
            orphanedContributions++;
            continue;
          }

          contributions.add(
            ContributionCollection()
              ..goalId = goalId
              ..amount = amount
              ..note = _asString(raw['note'])
              ..date = date
              ..createdAt = _asDate(raw['createdAt']) ?? date,
          );
        }
        await isar.contributionCollections.putAll(contributions);
        restoredContributions = contributions.length;
        if (orphanedContributions > 0) {
          skipped.add(
            '$orphanedContributions contribution(s) had no matching goal',
          );
        }
        if (version == 1 && restoredGoals > 0) {
          skipped.add(
            'Version 1 backups do not store contribution history; goal totals '
            'were restored without it',
          );
        }

        // --- Vision items ---
        var droppedVisions = 0;
        final visions = <VisionItemCollection>[];
        for (final raw in _asList(data['visions'])) {
          final title = _asString(raw['title']);
          final category = _enumByName(VisionCategory.values, raw['category']);
          if (title == null || category == null) {
            droppedVisions++;
            continue;
          }

          // A v1 'goalId' points into the old id space and cannot be remapped,
          // so the link is dropped rather than guessed at.
          final goalRef = version >= 2 ? _asInt(raw['goalRef']) : null;

          visions.add(
            VisionItemCollection()
              ..title = title
              ..description = _asString(raw['description'])
              ..imagePath = _asString(raw['imagePath'])
              ..quote = _asString(raw['quote'])
              ..goalId = goalRef == null ? null : newGoalIdByRef[goalRef]
              ..category = category
              ..isPinned = _asBool(raw['isPinned']) ?? false
              ..createdAt = _asDate(raw['createdAt']) ?? DateTime.now()
              ..updatedAt = _asDate(raw['updatedAt']) ?? DateTime.now(),
          );
        }
        await isar.visionItemCollections.putAll(visions);
        restoredVisions = visions.length;
        if (droppedVisions > 0) {
          skipped.add('$droppedVisions vision item(s) were malformed');
        }

        // --- Gamification (version 2+) ---
        final gamification = data['gamification'];
        if (gamification is Map<String, dynamic>) {
          await isar.userProgressCollections.put(
            UserProgressCollection()
              ..id = 1
              ..totalXp = _asInt(gamification['totalXp']) ?? 0
              ..currentLevel = _asInt(gamification['currentLevel']) ?? 1,
          );

          await isar.streakCollections.put(
            StreakCollection()
              ..id = 1
              ..currentStreak = _asInt(gamification['currentStreak']) ?? 0
              ..longestStreak = _asInt(gamification['longestStreak']) ?? 0
              ..lastActivityDate = _asDate(gamification['lastActivityDate']),
          );

          // Achievements are seeded by the app, so unlock the existing rows by
          // key rather than replacing the catalogue with the backup's copy.
          for (final raw in _asList(gamification['unlockedAchievements'])) {
            final key = _asString(raw['key']);
            if (key == null) continue;

            final achievement = await isar.achievementCollections
                .where()
                .keyEqualTo(key)
                .findFirst();
            if (achievement == null) continue;

            achievement.isUnlocked = true;
            achievement.unlockedAt =
                _asDate(raw['unlockedAt']) ?? DateTime.now();
            await isar.achievementCollections.put(achievement);
            unlockedAchievements++;
          }

          final xpRecords = <XpRecordCollection>[];
          for (final raw in _asList(gamification['xpRecords'])) {
            final amount = _asInt(raw['amount']);
            final reason = _asString(raw['reason']);
            final timestamp = _asDate(raw['timestamp']);
            if (amount == null || reason == null || timestamp == null) continue;

            xpRecords.add(
              XpRecordCollection()
                ..amount = amount
                ..reason = reason
                ..timestamp = timestamp,
            );
          }
          await isar.xpRecordCollections.putAll(xpRecords);
        } else if (version == 1) {
          skipped.add('Version 1 backups do not store XP or streak progress');
        }

        // --- Appearance ---
        // Merged into the existing settings row so the seed flags survive.
        final appearance = data['appearance'];
        if (appearance is Map<String, dynamic>) {
          final settings = await isar.appSettingsCollections.get(1) ??
              (AppSettingsCollection()..id = 1);
          settings.accentColorIndex = _asInt(appearance['accentColorIndex']);
          settings.customAccentColorValue =
              _asInt(appearance['customAccentColorValue']);
          await isar.appSettingsCollections.put(settings);
        }
      });
    } on AppException {
      rethrow;
    } catch (e, stack) {
      throw DatabaseException(
        message: 'The backup could not be restored. $e',
        stackTrace: stack,
      );
    }

    return BackupRestoreResult(
      transactions: restoredTransactions,
      goals: restoredGoals,
      contributions: restoredContributions,
      visionItems: restoredVisions,
      achievementsUnlocked: unlockedAchievements,
      skipped: skipped,
    );
  }

  // ---------------------------------------------------------------------------
  // CSV export
  // ---------------------------------------------------------------------------

  /// Exports every transaction as a spreadsheet-friendly CSV.
  ///
  /// Returns the file path, or `null` if the user cancelled the save dialog.
  Future<String?> exportTransactionsCsv() async {
    try {
      final transactions =
          await isar.transactionCollections.where().sortByDateDesc().findAll();

      final rows = <List<dynamic>>[
        ['Date', 'Title', 'Amount', 'Type', 'Category', 'Notes'],
        for (final t in transactions)
          [
            DateFormat('yyyy-MM-dd HH:mm').format(t.date),
            t.title,
            t.amount,
            t.type.name,
            t.category.name,
            t.notes ?? '',
          ],
      ];

      final csvData = csv.encode(rows);

      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export Transactions as CSV',
        fileName: 'kosh_transactions_$formattedDate.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile == null) return null;

      await File(outputFile).writeAsString(csvData);
      return outputFile;
    } catch (e, stack) {
      throw StorageException(
        message: 'Could not export the CSV file. $e',
        stackTrace: stack,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Defensive parsing
  //
  // A backup file is user-supplied input: it may be hand-edited, truncated, or
  // written by an older build. Every field is coerced rather than cast so one
  // bad row cannot abort the whole restore.
  // ---------------------------------------------------------------------------

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  static String? _asString(dynamic value) {
    if (value is String) return value.isEmpty ? null : value;
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value, caseSensitive: false);
    return null;
  }

  static DateTime? _asDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Resolves an enum by its `name`, returning `null` for unknown values
  /// instead of throwing the way `firstWhere` does.
  static T? _enumByName<T extends Enum>(List<T> values, dynamic name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
