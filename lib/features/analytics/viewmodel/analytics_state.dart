import '../models/analytics_summary.dart';
import '../models/category_summary.dart';
import '../models/goal_analytics.dart';
import '../models/monthly_summary.dart';
import '../repository/analytics_repository.dart';

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
    this.report,
    this.error,
  });

  final bool isLoading;
  final TimeFilter selectedTimeFilter;

  /// Null until the first load completes.
  final AnalyticsReport? report;

  final String? error;

  /// Whether a report has already been loaded, so a background refresh can
  /// leave the current content on screen instead of flashing a spinner.
  bool get hasData => report != null;

  AnalyticsSummary get summary => report?.summary ?? const AnalyticsSummary.empty();

  List<CategorySummary> get expenseBreakdown => summary.expenseBreakdown;

  List<CategorySummary> get incomeSources => summary.incomeSources;

  List<MonthlySummary> get monthlyTrends => summary.monthlyTrends;

  PeriodTotals get totals => summary.totals;

  GoalAnalytics? get goalAnalytics => report?.goals;

  AnalyticsState copyWith({
    bool? isLoading,
    TimeFilter? selectedTimeFilter,
    AnalyticsReport? report,
    String? error,
    bool clearError = false,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
      report: report ?? this.report,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
