import 'package:flutter_test/flutter_test.dart';
import 'package:kosh/core/services/analytics_calculator_service.dart';
import 'package:kosh/database/collections/goal_collection.dart';
import 'package:kosh/database/collections/transaction_collection.dart';
import 'package:kosh/features/goals/models/goal_category.dart';
import 'package:kosh/features/goals/models/goal_priority.dart';
import 'package:kosh/features/transactions/models/transaction_category.dart';
import 'package:kosh/features/transactions/models/transaction_type.dart';

TransactionCollection tx({
  required double amount,
  required TransactionType type,
  TransactionCategory category = TransactionCategory.other,
  DateTime? date,
}) {
  final on = date ?? DateTime(2026, 5, 15);
  return TransactionCollection()
    ..title = 'test'
    ..amount = amount
    ..type = type
    ..category = category
    ..date = on
    ..createdAt = on
    ..updatedAt = on;
}

TransactionCollection income(
  double amount, {
  TransactionCategory category = TransactionCategory.salary,
  DateTime? date,
}) =>
    tx(
      amount: amount,
      type: TransactionType.income,
      category: category,
      date: date,
    );

TransactionCollection expense(
  double amount, {
  TransactionCategory category = TransactionCategory.food,
  DateTime? date,
}) =>
    tx(
      amount: amount,
      type: TransactionType.expense,
      category: category,
      date: date,
    );

GoalCollection goal({
  required double target,
  required double current,
  bool isCompleted = false,
}) {
  return GoalCollection()
    ..title = 'goal'
    ..targetAmount = target
    ..currentAmount = current
    ..isCompleted = isCompleted
    ..deadline = DateTime(2027)
    ..category = GoalCategory.values.first
    ..priority = GoalPriority.values.first
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
}

void main() {
  group('summarize', () {
    test('an empty list produces zeroed totals and no buckets', () {
      final result = AnalyticsCalculatorService.summarize([]);

      expect(result.totals.income, 0);
      expect(result.totals.expense, 0);
      expect(result.totals.savings, 0);
      expect(result.totals.savingsRate, 0);
      expect(result.expenseBreakdown, isEmpty);
      expect(result.incomeSources, isEmpty);
      expect(result.monthlyTrends, isEmpty);
    });

    test('separates income from expense in the totals', () {
      final result = AnalyticsCalculatorService.summarize([
        income(5000),
        income(1000),
        expense(2000),
      ]);

      expect(result.totals.income, 6000);
      expect(result.totals.expense, 2000);
      expect(result.totals.savings, 4000);
      expect(result.totals.savingsRate, closeTo(66.67, 0.01));
    });

    test('reports a zero savings rate when spending exceeds income', () {
      final result = AnalyticsCalculatorService.summarize([
        income(1000),
        expense(2500),
      ]);

      expect(result.totals.savings, -1500);
      // Negative savings still reads as zero progress, not a negative bar.
      expect(result.totals.savingsRate, 0);
    });

    test('groups expenses by category, largest first, with percentages', () {
      final result = AnalyticsCalculatorService.summarize([
        expense(100, category: TransactionCategory.food),
        expense(300, category: TransactionCategory.food),
        expense(600, category: TransactionCategory.transport),
        income(9999),
      ]);

      expect(result.expenseBreakdown, hasLength(2));

      expect(result.expenseBreakdown.first.category,
          TransactionCategory.transport);
      expect(result.expenseBreakdown.first.totalAmount, 600);
      expect(result.expenseBreakdown.first.percentage, 60);

      expect(result.expenseBreakdown.last.category, TransactionCategory.food);
      expect(result.expenseBreakdown.last.totalAmount, 400);
      expect(result.expenseBreakdown.last.percentage, 40);
    });

    test('income percentages are of income, not of all activity', () {
      final result = AnalyticsCalculatorService.summarize([
        income(750, category: TransactionCategory.salary),
        income(250, category: TransactionCategory.freelance),
        expense(1000, category: TransactionCategory.food),
      ]);

      expect(result.incomeSources.first.category, TransactionCategory.salary);
      expect(result.incomeSources.first.percentage, 75);
      expect(result.incomeSources.last.percentage, 25);
    });

    test('buckets by month and orders oldest first across a year boundary',
        () {
      final result = AnalyticsCalculatorService.summarize([
        expense(50, date: DateTime(2026, 1, 5)),
        income(200, date: DateTime(2025, 12, 31)),
        income(100, date: DateTime(2025, 11, 2)),
        expense(25, date: DateTime(2025, 11, 20)),
      ]);

      expect(
        result.monthlyTrends.map((m) => '${m.year}-${m.month}'),
        ['2025-11', '2025-12', '2026-1'],
      );

      final november = result.monthlyTrends.first;
      expect(november.income, 100);
      expect(november.expense, 25);
      expect(november.savings, 75);

      final january = result.monthlyTrends.last;
      expect(january.income, 0);
      expect(january.expense, 50);
    });

    test('a month with only expenses still appears in the trend', () {
      final result = AnalyticsCalculatorService.summarize([
        expense(80, date: DateTime(2026, 3, 10)),
      ]);

      expect(result.monthlyTrends, hasLength(1));
      expect(result.monthlyTrends.single.month, 3);
      expect(result.monthlyTrends.single.income, 0);
      expect(result.monthlyTrends.single.expense, 80);
    });

    test('December maps to month 12, not to the following year', () {
      // Guards the months-since-year-zero key arithmetic at the wrap point.
      final result = AnalyticsCalculatorService.summarize([
        income(10, date: DateTime(2026, 12, 1)),
      ]);

      expect(result.monthlyTrends.single.year, 2026);
      expect(result.monthlyTrends.single.month, 12);
    });
  });

  group('calculateGoalAnalytics', () {
    test('counts active and completed goals and sums their amounts', () {
      final result = AnalyticsCalculatorService.calculateGoalAnalytics([
        goal(target: 1000, current: 250),
        goal(target: 4000, current: 4000, isCompleted: true),
      ]);

      expect(result.activeGoalsCount, 1);
      expect(result.completedGoalsCount, 1);
      expect(result.totalGoalTarget, 5000);
      expect(result.totalSaved, 4250);
      expect(result.overallCompletionPercentage, 85);
    });

    test('orders goals by how close they are to completion', () {
      final result = AnalyticsCalculatorService.calculateGoalAnalytics([
        goal(target: 1000, current: 100),
        goal(target: 1000, current: 900),
        goal(target: 1000, current: 500),
      ]);

      expect(
        result.goals.map((g) => g.currentAmount),
        [900, 500, 100],
      );
    });

    test('a zero-target goal does not divide by zero', () {
      final result = AnalyticsCalculatorService.calculateGoalAnalytics([
        goal(target: 0, current: 0),
      ]);

      expect(result.overallCompletionPercentage, 0);
      expect(result.goals, hasLength(1));
    });

    test('no goals yields an empty, zeroed analytic', () {
      final result = AnalyticsCalculatorService.calculateGoalAnalytics([]);

      expect(result.goals, isEmpty);
      expect(result.totalGoalTarget, 0);
      expect(result.overallCompletionPercentage, 0);
    });
  });
}
