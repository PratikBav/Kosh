import '../../../../database/collections/goal_collection.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../../../database/repositories/goals_repository.dart';
import '../../../../database/repositories/transaction_repository.dart';
import '../../transactions/models/transaction_type.dart';
import '../models/dashboard_summary.dart';

/// Aggregation repository that consumes Transactions and Goals repositories.
class DashboardRepository {
  DashboardRepository({
    required this.transactionsRepository,
    required this.goalsRepository,
  });

  final TransactionRepository transactionsRepository;
  final GoalsRepository goalsRepository;

  /// Fetches all data needed for the dashboard and aggregates it.
  Future<DashboardSummary> getDashboardSummary() async {
    final now = DateTime.now();

    // 1. Fetch data concurrently
    final results = await Future.wait([
      transactionsRepository.getAllTransactions(),
      transactionsRepository.getMonthlyTransactions(now.year, now.month),
      goalsRepository.getAllGoals(),
    ]);

    final allTx = results[0] as List<TransactionCollection>;
    final monthlyTx = results[1] as List<TransactionCollection>;
    final allGoals = results[2] as List<GoalCollection>;

    // 2. Aggregate Transactions
    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in allTx) {
      if (tx.type == TransactionType.income) totalIncome += tx.amount;
      if (tx.type == TransactionType.expense) totalExpense += tx.amount;
    }
    final netSavings = totalIncome - totalExpense;

    double monthlyIncome = 0;
    double monthlyExpense = 0;
    for (final tx in monthlyTx) {
      if (tx.type == TransactionType.income) monthlyIncome += tx.amount;
      if (tx.type == TransactionType.expense) monthlyExpense += tx.amount;
    }

    // Savings Rate (Monthly)
    double savingsRate = 0;
    if (monthlyIncome > 0) {
      final monthlySavings = monthlyIncome - monthlyExpense;
      if (monthlySavings > 0) {
        savingsRate = (monthlySavings / monthlyIncome) * 100;
      }
    }

    // Recent Transactions (top 5 by date)
    final sortedTx = List<TransactionCollection>.from(allTx)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTx.take(5).toList();

    // 3. Aggregate Goals
    int activeGoalsCount = 0;
    int completedGoalsCount = 0;
    double totalTarget = 0;
    double totalSaved = 0;

    for (final goal in allGoals) {
      totalTarget += goal.targetAmount;
      totalSaved += goal.currentAmount;
      if (goal.isCompleted) {
        completedGoalsCount++;
      } else {
        activeGoalsCount++;
      }
    }

    // Top 3 active goals by closest deadline
    final activeGoals = allGoals.where((g) => !g.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    final topGoals = activeGoals.take(3).toList();

    return DashboardSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      savingsRate: savingsRate,
      activeGoals: activeGoalsCount,
      completedGoals: completedGoalsCount,
      totalGoalTarget: totalTarget,
      totalGoalSaved: totalSaved,
      recentTransactions: recentTransactions,
      topGoals: topGoals,
    );
  }
}
