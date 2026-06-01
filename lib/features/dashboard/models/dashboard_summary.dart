import '../../../../database/collections/goal_collection.dart';
import '../../../../database/collections/transaction_collection.dart';

/// Aggregated data model for the Dashboard UI.
class DashboardSummary {
  DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.savingsRate,
    required this.activeGoals,
    required this.completedGoals,
    required this.totalGoalTarget,
    required this.totalGoalSaved,
    required this.recentTransactions,
    required this.topGoals,
  });

  final double totalIncome;
  final double totalExpense;
  final double netSavings;

  final double monthlyIncome;
  final double monthlyExpense;

  /// Expressed as a percentage (0 to 100)
  final double savingsRate;

  final int activeGoals;
  final int completedGoals;
  final double totalGoalTarget;
  final double totalGoalSaved;

  final List<TransactionCollection> recentTransactions;
  final List<GoalCollection> topGoals;

  factory DashboardSummary.empty() {
    return DashboardSummary(
      totalIncome: 0,
      totalExpense: 0,
      netSavings: 0,
      monthlyIncome: 0,
      monthlyExpense: 0,
      savingsRate: 0,
      activeGoals: 0,
      completedGoals: 0,
      totalGoalTarget: 0,
      totalGoalSaved: 0,
      recentTransactions: [],
      topGoals: [],
    );
  }
}
