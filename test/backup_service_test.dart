import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kosh/core/errors/app_exception.dart';
import 'package:kosh/core/services/backup_service.dart';
import 'package:kosh/database/collections/contribution_collection.dart';
import 'package:kosh/database/collections/goal_collection.dart';
import 'package:kosh/database/collections/transaction_collection.dart';
import 'package:kosh/database/collections/vision_item_collection.dart';
import 'package:kosh/features/goals/models/goal_category.dart';
import 'package:kosh/features/goals/models/goal_priority.dart';
import 'package:kosh/features/transactions/models/transaction_category.dart';
import 'package:kosh/features/transactions/models/transaction_type.dart';

import 'helpers/test_database.dart';

/// These tests run Isar against a real on-disk database in a temp directory,
/// which is the only way to exercise the id remapping that restore depends on.
void main() {
  late TestDatabase db;
  late Isar isar;
  late BackupService service;

  setUpAll(TestDatabase.ensureInitialized);

  setUp(() async {
    db = await TestDatabase.open('kosh_backup_test');
    isar = db.isar;
    service = BackupService(isar);
  });

  tearDown(() => db.close());

  GoalCollection buildGoal(String title, double target) {
    return GoalCollection()
      ..title = title
      ..targetAmount = target
      ..currentAmount = 0
      ..deadline = DateTime(2027, 1, 1)
      ..category = GoalCategory.values.first
      ..priority = GoalPriority.values.first
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1);
  }

  ContributionCollection buildContribution(int goalId, double amount) {
    return ContributionCollection()
      ..goalId = goalId
      ..amount = amount
      ..date = DateTime(2026, 6, 1)
      ..createdAt = DateTime(2026, 6, 1);
  }

  group('backup round trip', () {
    test('contributions stay attached to their own goal after restore',
        () async {
      // Two goals with distinguishable contribution amounts. The original bug
      // surfaced because restored goals get fresh ids, so contributions keyed
      // by the old id silently landed on the wrong goal.
      late int carId;
      late int houseId;

      await isar.writeTxn(() async {
        carId = await isar.goalCollections.put(buildGoal('Car', 500000));
        houseId = await isar.goalCollections.put(buildGoal('House', 2000000));
        await isar.contributionCollections.putAll([
          buildContribution(carId, 1000),
          buildContribution(carId, 2000),
          buildContribution(houseId, 9000),
        ]);
      });

      final payload = await service.buildBackupPayload();

      // Wipe and re-seed with a decoy so restored goals cannot reuse the
      // original ids — this is what makes the remap observable.
      await isar.writeTxn(() async {
        await isar.goalCollections.clear();
        await isar.contributionCollections.clear();
        for (var i = 0; i < 5; i++) {
          await isar.goalCollections.put(buildGoal('Decoy $i', 1));
        }
      });

      final result = await service.restoreFromBackup(payload);

      expect(result.goals, 2);
      expect(result.contributions, 3);

      final restoredGoals =
          await isar.goalCollections.where().sortByTitle().findAll();
      expect(restoredGoals.map((g) => g.title), ['Car', 'House']);

      final car = restoredGoals.firstWhere((g) => g.title == 'Car');
      final house = restoredGoals.firstWhere((g) => g.title == 'House');

      final carContributions = await isar.contributionCollections
          .filter()
          .goalIdEqualTo(car.id)
          .findAll();
      final houseContributions = await isar.contributionCollections
          .filter()
          .goalIdEqualTo(house.id)
          .findAll();

      expect(
        carContributions.map((c) => c.amount).toList()..sort(),
        [1000.0, 2000.0],
      );
      expect(houseContributions.map((c) => c.amount), [9000.0]);
    });

    test('restore clears contributions that the backup does not contain',
        () async {
      await isar.writeTxn(() async {
        final goalId = await isar.goalCollections.put(buildGoal('Old', 100));
        await isar.contributionCollections
            .put(buildContribution(goalId, 12345));
      });

      // A payload with a goal but no contributions at all.
      final payload = await service.buildBackupPayload();
      payload['contributions'] = <Map<String, dynamic>>[];

      await service.restoreFromBackup(payload);

      // The stale 12345 contribution must not survive the restore.
      expect(await isar.contributionCollections.count(), 0);
    });

    test('transactions and vision links survive a round trip', () async {
      await isar.writeTxn(() async {
        final goalId = await isar.goalCollections.put(buildGoal('Trip', 50000));
        await isar.transactionCollections.put(
          TransactionCollection()
            ..title = 'Salary'
            ..amount = 4200.50
            ..type = TransactionType.income
            ..category = TransactionCategory.values.first
            ..date = DateTime(2026, 5, 20)
            ..notes = 'May'
            ..createdAt = DateTime(2026, 5, 20)
            ..updatedAt = DateTime(2026, 5, 20),
        );
        await isar.visionItemCollections.put(
          VisionItemCollection()
            ..title = 'Iceland'
            ..category = VisionCategory.travel
            ..goalId = goalId
            ..isPinned = true
            ..createdAt = DateTime(2026, 1, 1)
            ..updatedAt = DateTime(2026, 1, 1),
        );
      });

      final payload = await service.buildBackupPayload();
      final result = await service.restoreFromBackup(payload);

      expect(result.transactions, 1);
      expect(result.visionItems, 1);

      final transaction =
          await isar.transactionCollections.where().findFirst();
      expect(transaction!.title, 'Salary');
      expect(transaction.amount, 4200.50);
      expect(transaction.type, TransactionType.income);

      final vision = await isar.visionItemCollections.where().findFirst();
      final goal = await isar.goalCollections.where().findFirst();
      expect(vision!.isPinned, isTrue);
      expect(vision.goalId, goal!.id);
    });
  });

  group('malformed input', () {
    test('rejects an unsupported version instead of wiping data', () async {
      await isar.writeTxn(() async {
        await isar.goalCollections.put(buildGoal('Keep me', 100));
      });

      expect(
        () => service.restoreFromBackup({'version': 99}),
        throwsA(isA<ValidationException>()),
      );

      expect(await isar.goalCollections.count(), 1);
    });

    test('skips rows with unknown enum names rather than throwing', () async {
      await isar.writeTxn(() async {
        await isar.goalCollections.put(buildGoal('Seed', 100));
      });

      final payload = await service.buildBackupPayload();
      payload['transactions'] = [
        {
          'title': 'Valid',
          'amount': 10,
          'type': 'income',
          'category': TransactionCategory.values.first.name,
          'date': '2026-05-20T00:00:00.000',
        },
        {
          'title': 'Bogus category',
          'amount': 10,
          'type': 'income',
          'category': 'category_removed_in_a_later_release',
          'date': '2026-05-20T00:00:00.000',
        },
      ];

      final result = await service.restoreFromBackup(payload);

      expect(result.transactions, 1);
      expect(result.hasSkipped, isTrue);
      expect(result.skipped.first, contains('malformed'));
    });

    test('accepts a version 1 backup and reports the missing history',
        () async {
      final legacy = {
        'version': 1,
        'transactions': <Map<String, dynamic>>[],
        'goals': [
          {
            'title': 'Legacy goal',
            'targetAmount': 1000,
            'currentAmount': 250,
            'deadline': '2027-01-01T00:00:00.000',
            'priority': GoalPriority.values.first.name,
            'category': GoalCategory.values.first.name,
            'isCompleted': false,
          },
        ],
        'visions': <Map<String, dynamic>>[],
      };

      final result = await service.restoreFromBackup(legacy);

      expect(result.goals, 1);
      expect(result.contributions, 0);
      expect(
        result.skipped.any((note) => note.contains('contribution history')),
        isTrue,
      );

      final goal = await isar.goalCollections.where().findFirst();
      expect(goal!.currentAmount, 250);
    });
  });
}
