import 'package:isar/isar.dart';

import '../collections/transaction_collection.dart';
import '../../features/transactions/models/transaction_type.dart';
import '../../features/transactions/models/transaction_category.dart';

/// Repository for handling [TransactionCollection] data operations.
class TransactionRepository {
  const TransactionRepository(this._isar);

  final Isar _isar;

  /// Adds a new transaction.
  Future<void> addTransaction(TransactionCollection transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionCollections.put(transaction);
    });
  }

  /// Updates an existing transaction.
  Future<void> updateTransaction(TransactionCollection transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionCollections.put(transaction);
    });
  }

  /// Deletes a transaction by ID.
  Future<void> deleteTransaction(int id) async {
    await _isar.writeTxn(() async {
      await _isar.transactionCollections.delete(id);
    });
  }

  /// Gets all transactions ordered by date descending.
  Future<List<TransactionCollection>> getAllTransactions() async {
    return await _isar.transactionCollections
        .where()
        .sortByDateDesc()
        .findAll();
  }

  /// Gets transactions for a specific month and year.
  Future<List<TransactionCollection>> getMonthlyTransactions(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59, 999);

    return getTransactionsBetween(startDate, endDate);
  }

  /// Gets transactions in an inclusive date range, newest first.
  ///
  /// Uses the `date` index rather than loading every row and filtering in
  /// Dart, which is what the analytics layer used to do on every refresh.
  Future<List<TransactionCollection>> getTransactionsBetween(
    DateTime start,
    DateTime end,
  ) async {
    return await _isar.transactionCollections
        .where()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  /// Sums every amount of [type] without materialising the rows.
  Future<double> totalAmountByType(TransactionType type) {
    return _isar.transactionCollections
        .where()
        .typeEqualTo(type)
        .amountProperty()
        .sum();
  }

  /// Total number of transactions on record.
  Future<int> count() => _isar.transactionCollections.count();

  /// Gets transactions by category.
  Future<List<TransactionCollection>> getTransactionsByCategory(TransactionCategory category) async {
    return await _isar.transactionCollections
        .where()
        .categoryEqualTo(category)
        .sortByDateDesc()
        .findAll();
  }

  /// Gets transactions by type.
  Future<List<TransactionCollection>> getTransactionsByType(TransactionType type) async {
    return await _isar.transactionCollections
        .where()
        .typeEqualTo(type)
        .sortByDateDesc()
        .findAll();
  }

  /// Searches transactions by title or notes.
  Future<List<TransactionCollection>> searchTransactions(String query) async {
    return await _isar.transactionCollections
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .notesContains(query, caseSensitive: false)
        .sortByDateDesc()
        .findAll();
  }
}
