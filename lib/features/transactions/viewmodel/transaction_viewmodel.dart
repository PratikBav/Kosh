import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/collections/transaction_collection.dart';
import '../../../../database/repositories/transaction_repository.dart';
import '../../../../providers/repository_providers.dart';
import '../models/transaction_category.dart';
import '../models/transaction_type.dart';
import '../../gamification/viewmodel/gamification_viewmodel.dart';
import 'transaction_state.dart';

/// Provider for the TransactionViewModel.
final transactionViewModelProvider =
    StateNotifierProvider<TransactionViewModel, TransactionState>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final gamification = ref.read(gamificationViewModelProvider.notifier);
  return TransactionViewModel(repository, gamification);
});

/// ViewModel for managing transactions.
class TransactionViewModel extends StateNotifier<TransactionState> {
  TransactionViewModel(this._repository, this._gamification) : super(const TransactionState()) {
    loadTransactions();
  }

  final TransactionRepository _repository;
  final GamificationViewModel _gamification;

  /// Loads transactions based on the current date range.
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      List<TransactionCollection> results;
      
      final now = DateTime.now();

      switch (state.selectedDateRange) {
        case DateRangeFilter.all:
          results = await _repository.getAllTransactions();
        case DateRangeFilter.thisMonth:
          results = await _repository.getMonthlyTransactions(now.year, now.month);
        case DateRangeFilter.lastMonth:
          final lastMonth = now.month == 1 ? 12 : now.month - 1;
          final year = now.month == 1 ? now.year - 1 : now.year;
          results = await _repository.getMonthlyTransactions(year, lastMonth);
        case DateRangeFilter.custom:
          // For simplicity in Phase 2, if custom is selected but no dates set, fallback to all.
          // In a real scenario, we'd query by exact range.
          results = await _repository.getAllTransactions();
          if (state.customStartDate != null && state.customEndDate != null) {
            results = results.where((t) {
              return t.date.isAfter(state.customStartDate!) && 
                     t.date.isBefore(state.customEndDate!.add(const Duration(days: 1)));
            }).toList();
          }
      }

      state = state.copyWith(
        transactions: results,
        isLoading: false,
      );
      
      // Re-apply local filters (type, category, search) on the newly loaded data
      _applyFilters();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load transactions: $e',
      );
    }
  }

  /// Adds a new transaction and reloads.
  Future<void> addTransaction(TransactionCollection transaction) async {
    try {
      await _repository.addTransaction(transaction);
      await loadTransactions();
      await _gamification.logTransactionActivity();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add transaction: $e');
    }
  }

  /// Updates an existing transaction and reloads.
  Future<void> updateTransaction(TransactionCollection transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update transaction: $e');
    }
  }

  /// Deletes a transaction and reloads.
  Future<void> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete transaction: $e');
    }
  }

  /// Sets the type filter and applies it.
  void setTypeFilter(TransactionType? type) {
    state = state.copyWith(
      selectedTypeFilter: type,
      clearTypeFilter: type == null,
    );
    _applyFilters();
  }

  /// Sets the category filter and applies it.
  void setCategoryFilter(TransactionCategory? category) {
    state = state.copyWith(
      selectedCategoryFilter: category,
      clearCategoryFilter: category == null,
    );
    _applyFilters();
  }

  /// Sets the date range filter and reloads from DB.
  void setDateRangeFilter(DateRangeFilter range, {DateTime? start, DateTime? end}) {
    state = state.copyWith(
      selectedDateRange: range,
      customStartDate: start,
      customEndDate: end,
    );
    loadTransactions();
  }

  /// Sets the search query and applies it.
  void searchTransactions(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Applies the current type, category, and search filters locally.
  void _applyFilters() {
    var filtered = List<TransactionCollection>.from(state.transactions);

    // Apply Type Filter
    if (state.selectedTypeFilter != null) {
      filtered = filtered.where((t) => t.type == state.selectedTypeFilter).toList();
    }

    // Apply Category Filter
    if (state.selectedCategoryFilter != null) {
      filtered = filtered.where((t) => t.category == state.selectedCategoryFilter).toList();
    }

    // Apply Search Query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(query) ||
               (t.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    state = state.copyWith(filteredTransactions: filtered);
  }
}
