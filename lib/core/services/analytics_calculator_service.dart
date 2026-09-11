import '../../database/collections/goal_collection.dart';
import '../../database/collections/transaction_collection.dart';
import '../../features/analytics/models/analytics_summary.dart';
import '../../features/analytics/models/category_summary.dart';
import '../../features/analytics/models/goal_analytics.dart';
import '../../features/analytics/models/monthly_summary.dart';
import '../../features/transactions/models/transaction_category.dart';
import '../../features/transactions/models/transaction_type.dart';

class AnalyticsCalculatorService {
  const AnalyticsCalculatorService._();

  /// Derives every transaction-based analytic in a single traversal.
  ///
  /// The category breakdowns, monthly trend and period totals all come from
  /// the same accumulation pass — computing them separately meant walking the
  /// same list four times over.
  static AnalyticsSummary summarize(List<TransactionCollection> transactions) {
    var totalIncome = 0.0;
    var totalExpense = 0.0;

    final expenseByCategory = <TransactionCategory, double>{};
    final incomeByCategory = <TransactionCategory, double>{};

    // Keyed by months-since-year-zero so the buckets sort chronologically
    // without string parsing.
    final incomeByMonth = <int, double>{};
    final expenseByMonth = <int, double>{};

    for (final transaction in transactions) {
      final monthKey = _monthKey(transaction.date);

      switch (transaction.type) {
        case TransactionType.income:
          totalIncome += transaction.amount;
          _add(incomeByCategory, transaction.category, transaction.amount);
          _add(incomeByMonth, monthKey, transaction.amount);
        case TransactionType.expense:
          totalExpense += transaction.amount;
          _add(expenseByCategory, transaction.category, transaction.amount);
          _add(expenseByMonth, monthKey, transaction.amount);
      }
    }

    final monthKeys = <int>{...incomeByMonth.keys, ...expenseByMonth.keys}
        .toList()
      ..sort();

    return AnalyticsSummary(
      expenseBreakdown: _toCategorySummaries(expenseByCategory, totalExpense),
      incomeSources: _toCategorySummaries(incomeByCategory, totalIncome),
      monthlyTrends: [
        for (final key in monthKeys)
          MonthlySummary(
            year: key ~/ 12,
            month: key % 12 + 1,
            income: incomeByMonth[key] ?? 0,
            expense: expenseByMonth[key] ?? 0,
          ),
      ],
      totals: PeriodTotals(income: totalIncome, expense: totalExpense),
    );
  }

  /// Aggregates all goal data into a [GoalAnalytics] object.
  static GoalAnalytics calculateGoalAnalytics(List<GoalCollection> goals) {
    var totalTarget = 0.0;
    var totalSaved = 0.0;
    var active = 0;
    var completed = 0;

    for (final goal in goals) {
      totalTarget += goal.targetAmount;
      totalSaved += goal.currentAmount;
      if (goal.isCompleted) {
        completed++;
      } else {
        active++;
      }
    }

    final sortedGoals = List<GoalCollection>.from(goals)
      ..sort((a, b) => _progress(b).compareTo(_progress(a)));

    return GoalAnalytics(
      totalGoalTarget: totalTarget,
      totalSaved: totalSaved,
      activeGoalsCount: active,
      completedGoalsCount: completed,
      goals: sortedGoals,
    );
  }

  static int _monthKey(DateTime date) => date.year * 12 + (date.month - 1);

  static double _progress(GoalCollection goal) {
    if (goal.targetAmount <= 0) return 0;
    return goal.currentAmount / goal.targetAmount;
  }

  static void _add<K>(Map<K, double> target, K key, double amount) {
    target.update(key, (value) => value + amount, ifAbsent: () => amount);
  }

  /// Converts category totals into percentage-bearing summaries, largest
  /// first. Returns empty when [total] is zero, which also avoids dividing
  /// by it.
  static List<CategorySummary> _toCategorySummaries(
    Map<TransactionCategory, double> totals,
    double total,
  ) {
    if (total <= 0) return const [];

    final summaries = [
      for (final entry in totals.entries)
        CategorySummary(
          category: entry.key,
          totalAmount: entry.value,
          percentage: (entry.value / total) * 100,
        ),
    ]..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return summaries;
  }
}
