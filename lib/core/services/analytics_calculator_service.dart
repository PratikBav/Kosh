import '../../database/collections/goal_collection.dart';
import '../../database/collections/transaction_collection.dart';
import '../../features/analytics/models/category_summary.dart';
import '../../features/analytics/models/goal_analytics.dart';
import '../../features/analytics/models/monthly_summary.dart';
import '../../features/transactions/models/transaction_category.dart';
import '../../features/transactions/models/transaction_type.dart';

class AnalyticsCalculatorService {
  
  /// Calculates expense breakdown by category for a list of transactions.
  static List<CategorySummary> calculateCategoryBreakdown(List<TransactionCollection> transactions) {
    final expenses = transactions.where((tx) => tx.type == TransactionType.expense);
    
    double totalExpense = 0;
    final Map<TransactionCategory, double> categoryTotals = {};
    
    for (final tx in expenses) {
      totalExpense += tx.amount;
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    
    if (totalExpense == 0) return [];

    final result = categoryTotals.entries.map((e) {
      return CategorySummary(
        category: e.key,
        totalAmount: e.value,
        percentage: (e.value / totalExpense) * 100,
      );
    }).toList();

    // Sort by amount descending
    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return result;
  }

  /// Calculates income breakdown by category for a list of transactions.
  static List<CategorySummary> calculateIncomeSources(List<TransactionCollection> transactions) {
    final incomes = transactions.where((tx) => tx.type == TransactionType.income);
    
    double totalIncome = 0;
    final Map<TransactionCategory, double> categoryTotals = {};
    
    for (final tx in incomes) {
      totalIncome += tx.amount;
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    
    if (totalIncome == 0) return [];

    final result = categoryTotals.entries.map((e) {
      return CategorySummary(
        category: e.key,
        totalAmount: e.value,
        percentage: (e.value / totalIncome) * 100,
      );
    }).toList();

    // Sort by amount descending
    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return result;
  }

  /// Groups transactions by month and returns a list of MonthlySummary.
  /// Typically expects transactions spanning several months.
  static List<MonthlySummary> calculateMonthlyTrend(List<TransactionCollection> transactions) {
    // Map key: "YYYY-MM"
    final Map<String, MonthlySummary> monthMap = {};

    for (final tx in transactions) {
      final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      
      if (!monthMap.containsKey(key)) {
        monthMap[key] = MonthlySummary(year: tx.date.year, month: tx.date.month, income: 0, expense: 0);
      }
      
      final current = monthMap[key]!;
      monthMap[key] = MonthlySummary(
        year: current.year,
        month: current.month,
        income: current.income + (tx.type == TransactionType.income ? tx.amount : 0),
        expense: current.expense + (tx.type == TransactionType.expense ? tx.amount : 0),
      );
    }

    final result = monthMap.values.toList();
    // Sort oldest to newest for charts
    result.sort((a, b) {
      if (a.year != b.year) return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });
    
    return result;
  }

  /// Aggregates all goal data into a GoalAnalytics object.
  static GoalAnalytics calculateGoalAnalytics(List<GoalCollection> goals) {
    double totalTarget = 0;
    double totalSaved = 0;
    int active = 0;
    int completed = 0;

    for (final goal in goals) {
      totalTarget += goal.targetAmount;
      totalSaved += goal.currentAmount;
      if (goal.isCompleted) {
        completed++;
      } else {
        active++;
      }
    }

    // Sort goals by completion percentage descending
    final sortedGoals = List<GoalCollection>.from(goals)
      ..sort((a, b) {
        final aPct = a.targetAmount > 0 ? (a.currentAmount / a.targetAmount) : 0;
        final bPct = b.targetAmount > 0 ? (b.currentAmount / b.targetAmount) : 0;
        return bPct.compareTo(aPct);
      });

    return GoalAnalytics(
      totalGoalTarget: totalTarget,
      totalSaved: totalSaved,
      activeGoalsCount: active,
      completedGoalsCount: completed,
      goals: sortedGoals,
    );
  }
}
