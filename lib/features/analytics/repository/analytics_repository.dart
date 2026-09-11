import '../../../../core/services/analytics_calculator_service.dart';
import '../../../../database/repositories/goals_repository.dart';
import '../../../../database/repositories/transaction_repository.dart';
import '../../transactions/models/transaction_type.dart';
import '../models/analytics_summary.dart';
import '../models/goal_analytics.dart';

/// Everything the analytics screen renders, gathered in one round trip.
class AnalyticsReport {
  const AnalyticsReport({required this.summary, required this.goals});

  const AnalyticsReport.empty()
      : summary = const AnalyticsSummary.empty(),
        goals = null;

  final AnalyticsSummary summary;
  final GoalAnalytics? goals;
}

class AnalyticsRepository {
  AnalyticsRepository({
    required this.transactionsRepository,
    required this.goalsRepository,
  });

  final TransactionRepository transactionsRepository;
  final GoalsRepository goalsRepository;

  /// Builds the full analytics report for a timeframe.
  ///
  /// One indexed range query feeds every transaction-derived figure. The
  /// previous shape exposed five methods that each re-read the whole
  /// transaction table and filtered it in Dart, so a single refresh cost five
  /// full scans.
  Future<AnalyticsReport> getReport(DateTime startDate, DateTime endDate) async {
    // Started together, awaited separately: Future.wait would erase both
    // element types to dynamic.
    final transactionsFuture =
        transactionsRepository.getTransactionsBetween(startDate, endDate);
    final goalsFuture = goalsRepository.getAllGoals();

    return AnalyticsReport(
      summary: AnalyticsCalculatorService.summarize(await transactionsFuture),
      goals: AnalyticsCalculatorService.calculateGoalAnalytics(
        await goalsFuture,
      ),
    );
  }

  /// Lifetime net savings, computed by the database rather than by loading
  /// every transaction. Used for milestone checks, which run on every XP
  /// award.
  Future<double> getLifetimeNetSavings() async {
    final totals = await Future.wait([
      transactionsRepository.totalAmountByType(TransactionType.income),
      transactionsRepository.totalAmountByType(TransactionType.expense),
    ]);

    return totals[0] - totals[1];
  }
}
