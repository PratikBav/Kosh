import '../../../../core/services/analytics_calculator_service.dart';
import '../../../../database/repositories/goals_repository.dart';
import '../../../../database/repositories/transaction_repository.dart';
import '../models/category_summary.dart';
import '../models/goal_analytics.dart';
import '../models/monthly_summary.dart';

class AnalyticsRepository {
  AnalyticsRepository({
    required this.transactionsRepository,
    required this.goalsRepository,
  });

  final TransactionRepository transactionsRepository;
  final GoalsRepository goalsRepository;

  /// Returns expense breakdown by category for the given timeframe
  Future<List<CategorySummary>> getExpenseAnalytics(DateTime startDate, DateTime endDate) async {
    final transactions = await transactionsRepository.getAllTransactions();
    // Filter locally for now, since Isar complex date filtering can be tricky with simple repos
    final filtered = transactions.where((tx) => 
      tx.date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
      tx.date.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
    
    return AnalyticsCalculatorService.calculateCategoryBreakdown(filtered);
  }

  /// Returns income sources for the given timeframe
  Future<List<CategorySummary>> getIncomeAnalytics(DateTime startDate, DateTime endDate) async {
    final transactions = await transactionsRepository.getAllTransactions();
    final filtered = transactions.where((tx) => 
      tx.date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
      tx.date.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
    
    return AnalyticsCalculatorService.calculateIncomeSources(filtered);
  }

  /// Returns monthly trends over the given timeframe
  Future<List<MonthlySummary>> getMonthlyTrends(DateTime startDate, DateTime endDate) async {
    final transactions = await transactionsRepository.getAllTransactions();
    final filtered = transactions.where((tx) => 
      tx.date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
      tx.date.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
    
    return AnalyticsCalculatorService.calculateMonthlyTrend(filtered);
  }

  /// Returns goal analytics
  Future<GoalAnalytics> getGoalAnalytics() async {
    final goals = await goalsRepository.getAllGoals();
    return AnalyticsCalculatorService.calculateGoalAnalytics(goals);
  }

  /// Get overall summary numbers for the selected timeframe
  Future<Map<String, double>> getOverallSummary(DateTime startDate, DateTime endDate) async {
    final transactions = await transactionsRepository.getAllTransactions();
    final filtered = transactions.where((tx) => 
      tx.date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
      tx.date.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
    
    // Quick aggregation using a dummy MonthlySummary wrapper to reuse the logic
    final summary = AnalyticsCalculatorService.calculateMonthlyTrend(filtered);
    
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (var s in summary) {
      totalIncome += s.income;
      totalExpense += s.expense;
    }
    
    double savingsRate = 0;
    if (totalIncome > 0) {
      final net = totalIncome - totalExpense;
      if (net > 0) savingsRate = (net / totalIncome) * 100;
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'savings': totalIncome - totalExpense,
      'savingsRate': savingsRate,
    };
  }
}
