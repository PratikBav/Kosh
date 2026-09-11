import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kosh/database/collections/transaction_collection.dart';
import 'package:kosh/database/repositories/goals_repository.dart';
import 'package:kosh/database/repositories/transaction_repository.dart';
import 'package:kosh/features/analytics/repository/analytics_repository.dart';
import 'package:kosh/features/transactions/models/transaction_category.dart';
import 'package:kosh/features/transactions/models/transaction_type.dart';

import 'helpers/test_database.dart';

void main() {
  late TestDatabase db;
  late Isar isar;
  late TransactionRepository transactions;
  late AnalyticsRepository analytics;

  setUpAll(TestDatabase.ensureInitialized);

  setUp(() async {
    db = await TestDatabase.open('kosh_analytics_test');
    isar = db.isar;
    transactions = TransactionRepository(isar);
    analytics = AnalyticsRepository(
      transactionsRepository: transactions,
      goalsRepository: GoalsRepository(isar),
    );
  });

  tearDown(() => db.close());

  Future<void> seed(List<(double, TransactionType, DateTime)> rows) {
    return isar.writeTxn(() async {
      await isar.transactionCollections.putAll([
        for (final (amount, type, date) in rows)
          TransactionCollection()
            ..title = 'seed'
            ..amount = amount
            ..type = type
            ..category = TransactionCategory.other
            ..date = date
            ..createdAt = date
            ..updatedAt = date,
      ]);
    });
  }

  group('getTransactionsBetween', () {
    test('returns only rows inside the range, newest first', () async {
      await seed([
        (10, TransactionType.expense, DateTime(2026, 1, 15)),
        (20, TransactionType.expense, DateTime(2026, 2, 10)),
        (30, TransactionType.expense, DateTime(2026, 2, 20)),
        (40, TransactionType.expense, DateTime(2026, 3, 5)),
      ]);

      final result = await transactions.getTransactionsBetween(
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 28, 23, 59, 59),
      );

      expect(result.map((t) => t.amount), [30, 20]);
    });

    test('range bounds are inclusive', () async {
      final start = DateTime(2026, 4, 1);
      final end = DateTime(2026, 4, 30);
      await seed([
        (1, TransactionType.expense, start),
        (2, TransactionType.expense, end),
      ]);

      final result = await transactions.getTransactionsBetween(start, end);
      expect(result, hasLength(2));
    });
  });

  group('getReport', () {
    test('summarises only the requested window', () async {
      await seed([
        (1000, TransactionType.income, DateTime(2026, 1, 10)),
        (5000, TransactionType.income, DateTime(2026, 2, 10)),
        (2000, TransactionType.expense, DateTime(2026, 2, 20)),
        (9999, TransactionType.income, DateTime(2026, 3, 1)),
      ]);

      final report = await analytics.getReport(
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 28, 23, 59, 59),
      );

      expect(report.summary.totals.income, 5000);
      expect(report.summary.totals.expense, 2000);
      expect(report.summary.totals.savings, 3000);
      expect(report.summary.monthlyTrends, hasLength(1));
    });

    test('an empty window reports zeroes rather than failing', () async {
      await seed([(1000, TransactionType.income, DateTime(2026, 1, 10))]);

      final report = await analytics.getReport(
        DateTime(2030, 1, 1),
        DateTime(2030, 12, 31),
      );

      expect(report.summary.totals.income, 0);
      expect(report.summary.expenseBreakdown, isEmpty);
      expect(report.goals, isNotNull);
    });
  });

  group('getLifetimeNetSavings', () {
    test('sums across all time regardless of date', () async {
      await seed([
        (10000, TransactionType.income, DateTime(1999, 5, 1)),
        (5000, TransactionType.income, DateTime(2026, 5, 1)),
        (3000, TransactionType.expense, DateTime(2026, 5, 2)),
      ]);

      expect(await analytics.getLifetimeNetSavings(), 12000);
    });

    test('returns zero on an empty database', () async {
      expect(await analytics.getLifetimeNetSavings(), 0);
    });

    test('goes negative when spending exceeds income', () async {
      await seed([
        (100, TransactionType.income, DateTime(2026, 5, 1)),
        (400, TransactionType.expense, DateTime(2026, 5, 2)),
      ]);

      expect(await analytics.getLifetimeNetSavings(), -300);
    });
  });
}
