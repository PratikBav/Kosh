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
    final monthStart = DateTime(now.year, now.month, 1);

    // 1. Fetch data concurrently. Awaited separately rather than through
    // Future.wait, which would erase both element types to dynamic.
    final transactionsFuture = transactionsRepository.getAllTransactions();
    final goalsFuture = goalsRepository.getAllGoals();

    final allTx = await transactionsFuture;
    final allGoals = await goalsFuture;

    // 2. Aggregate transactions in a single pass. The month's figures are
    // derived here too, rather than issuing a second query for rows already
    // in hand.
    double totalIncome = 0;
    double totalExpense = 0;
    double monthlyIncome = 0;
    double monthlyExpense = 0;

    for (final tx in allTx) {
      final isThisMonth = !tx.date.isBefore(monthStart);

      switch (tx.type) {
        case TransactionType.income:
          totalIncome += tx.amount;
          if (isThisMonth) monthlyIncome += tx.amount;
        case TransactionType.expense:
          totalExpense += tx.amount;
          if (isThisMonth) monthlyExpense += tx.amount;
      }
    }

    final netSavings = totalIncome - totalExpense;

    // Savings Rate (Monthly)
    double savingsRate = 0;
    if (monthlyIncome > 0) {
      final monthlySavings = monthlyIncome - monthlyExpense;
      if (monthlySavings > 0) {
        savingsRate = (monthlySavings / monthlyIncome) * 100;
      }
    }

    // Recent Transactions — the repository already returns them newest first.
    final recentTransactions = allTx.take(5).toList();

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
