import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/collections/transaction_collection.dart';
import '../../features/transactions/models/transaction_type.dart';

/// Provides the [FinanceCalculatorService].
final financeCalculatorServiceProvider = Provider<FinanceCalculatorService>((ref) {
  return FinanceCalculatorService();
});

/// A service to perform calculations on a list of transactions.
class FinanceCalculatorService {
  /// Calculates the total income from a list of transactions.
  double getTotalIncome(List<TransactionCollection> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculates the total expense from a list of transactions.
  double getTotalExpense(List<TransactionCollection> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculates net savings (income - expense).
  double getNetSavings(List<TransactionCollection> transactions) {
    return getTotalIncome(transactions) - getTotalExpense(transactions);
  }

  /// Returns a summary containing income, expense, and net savings.
  Map<String, double> getMonthlySummary(List<TransactionCollection> transactions) {
    final income = getTotalIncome(transactions);
    final expense = getTotalExpense(transactions);
    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
    };
  }
}
