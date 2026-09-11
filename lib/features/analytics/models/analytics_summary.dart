import 'category_summary.dart';
import 'monthly_summary.dart';

/// Income, expense and derived savings figures for a period.
class PeriodTotals {
  const PeriodTotals({this.income = 0, this.expense = 0});

  final double income;
  final double expense;

  double get savings => income - expense;

  /// Share of income kept, as a percentage.
  ///
  /// Zero when there was no income, or when spending exceeded it — a negative
  /// savings rate reads as a bug in a progress indicator.
  double get savingsRate {
    if (income <= 0) return 0;
    final rate = (savings / income) * 100;
    return rate < 0 ? 0 : rate;
  }
}

/// Everything the analytics screen needs from one pass over a period's
/// transactions.
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.expenseBreakdown,
    required this.incomeSources,
    required this.monthlyTrends,
    required this.totals,
  });

  const AnalyticsSummary.empty()
      : expenseBreakdown = const [],
        incomeSources = const [],
        monthlyTrends = const [],
        totals = const PeriodTotals();

  /// Expense categories, largest first.
  final List<CategorySummary> expenseBreakdown;

  /// Income categories, largest first.
  final List<CategorySummary> incomeSources;

  /// Months that saw activity, oldest first.
  final List<MonthlySummary> monthlyTrends;

  final PeriodTotals totals;
}
