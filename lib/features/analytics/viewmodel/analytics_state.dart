import '../models/category_summary.dart';
import '../models/goal_analytics.dart';
import '../models/monthly_summary.dart';

enum TimeFilter { thisMonth, lastMonth, threeMonths, sixMonths, oneYear, allTime }

extension TimeFilterExtension on TimeFilter {
  String get label {
    switch (this) {
      case TimeFilter.thisMonth: return 'This Month';
      case TimeFilter.lastMonth: return 'Last Month';
      case TimeFilter.threeMonths: return '3 Months';
      case TimeFilter.sixMonths: return '6 Months';
      case TimeFilter.oneYear: return '1 Year';
      case TimeFilter.allTime: return 'All Time';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case TimeFilter.thisMonth:
        return DateTime(now.year, now.month, 1);
      case TimeFilter.lastMonth:
        return DateTime(now.year, now.month - 1, 1);
      case TimeFilter.threeMonths:
        return DateTime(now.year, now.month - 3, 1);
      case TimeFilter.sixMonths:
        return DateTime(now.year, now.month - 6, 1);
      case TimeFilter.oneYear:
        return DateTime(now.year - 1, now.month, now.day);
      case TimeFilter.allTime:
        return DateTime(1970);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (this) {
      case TimeFilter.lastMonth:
        return DateTime(now.year, now.month, 0, 23, 59, 59); // Last day of last month
      default:
        return now;
    }
  }
}

class AnalyticsState {
  const AnalyticsState({
    this.isLoading = true,
    this.selectedTimeFilter = TimeFilter.thisMonth,
    this.expenseBreakdown = const [],
    this.incomeSources = const [],
    this.monthlyTrends = const [],
    this.goalAnalytics,
    this.overallSummary = const {},
    this.error,
  });

  final bool isLoading;
  final TimeFilter selectedTimeFilter;
  final List<CategorySummary> expenseBreakdown;
  final List<CategorySummary> incomeSources;
  final List<MonthlySummary> monthlyTrends;
  final GoalAnalytics? goalAnalytics;
  final Map<String, double> overallSummary;
  final String? error;

  AnalyticsState copyWith({
    bool? isLoading,
    TimeFilter? selectedTimeFilter,
    List<CategorySummary>? expenseBreakdown,
    List<CategorySummary>? incomeSources,
    List<MonthlySummary>? monthlyTrends,
    GoalAnalytics? goalAnalytics,
    Map<String, double>? overallSummary,
    String? error,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      incomeSources: incomeSources ?? this.incomeSources,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      goalAnalytics: goalAnalytics ?? this.goalAnalytics,
      overallSummary: overallSummary ?? this.overallSummary,
      error: error,
    );
  }
}
