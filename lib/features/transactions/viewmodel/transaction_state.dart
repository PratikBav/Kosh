import '../../../../database/collections/transaction_collection.dart';
import '../models/transaction_category.dart';
import '../models/transaction_type.dart';

/// Represents a date range filter.
enum DateRangeFilter {
  all,
  thisMonth,
  lastMonth,
  custom;

  String get label {
    switch (this) {
      case DateRangeFilter.all:
        return 'All Time';
      case DateRangeFilter.thisMonth:
        return 'This Month';
      case DateRangeFilter.lastMonth:
        return 'Last Month';
      case DateRangeFilter.custom:
        return 'Custom';
    }
  }
}

/// The state for the Transactions feature.
class TransactionState {
  const TransactionState({
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedTypeFilter,
    this.selectedCategoryFilter,
    this.selectedDateRange = DateRangeFilter.thisMonth,
    this.searchQuery = '',
    this.customStartDate,
    this.customEndDate,
  });

  /// All raw transactions fetched based on date range.
  final List<TransactionCollection> transactions;

  /// Transactions after applying type, category, and search filters.
  final List<TransactionCollection> filteredTransactions;

  final bool isLoading;
  final String? errorMessage;

  // Filters
  final TransactionType? selectedTypeFilter;
  final TransactionCategory? selectedCategoryFilter;
  final DateRangeFilter selectedDateRange;
  final String searchQuery;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  TransactionState copyWith({
    List<TransactionCollection>? transactions,
    List<TransactionCollection>? filteredTransactions,
    bool? isLoading,
    String? errorMessage,
    TransactionType? selectedTypeFilter,
    TransactionCategory? selectedCategoryFilter,
    DateRangeFilter? selectedDateRange,
    String? searchQuery,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool clearTypeFilter = false,
    bool clearCategoryFilter = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedTypeFilter: clearTypeFilter ? null : (selectedTypeFilter ?? this.selectedTypeFilter),
      selectedCategoryFilter: clearCategoryFilter ? null : (selectedCategoryFilter ?? this.selectedCategoryFilter),
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      searchQuery: searchQuery ?? this.searchQuery,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}
