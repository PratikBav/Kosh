import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../database/collections/contribution_collection.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../../../providers/database_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../models/category_summary.dart';
import '../models/monthly_summary.dart';
import '../repository/analytics_repository.dart';
import 'analytics_state.dart';

final analyticsViewModelProvider = StateNotifierProvider<AnalyticsViewModel, AnalyticsState>((ref) {
  final isar = ref.watch(isarProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return AnalyticsViewModel(isar, repo);
});

class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  AnalyticsViewModel(this._isar, this._repository) : super(const AnalyticsState()) {
    _init();
  }

  final Isar _isar;
  final AnalyticsRepository _repository;
  
  StreamSubscription<void>? _transactionsSub;
  StreamSubscription<void>? _goalsSub;
  StreamSubscription<void>? _contributionsSub;

  void _init() {
    loadAnalytics();
    _setupWatchers();
  }

  void _setupWatchers() {
    _transactionsSub = _isar.transactionCollections.watchLazy().listen((_) => loadAnalytics());
    _goalsSub = _isar.goalCollections.watchLazy().listen((_) => loadAnalytics());
    _contributionsSub = _isar.contributionCollections.watchLazy().listen((_) => loadAnalytics());
  }

  void setTimeFilter(TimeFilter filter) {
    if (state.selectedTimeFilter == filter) return;
    state = state.copyWith(selectedTimeFilter: filter);
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      if (state.expenseBreakdown.isEmpty) {
        state = state.copyWith(isLoading: true, error: null);
      }
      
      final filter = state.selectedTimeFilter;
      final start = filter.startDate;
      final end = filter.endDate;

      final results = await Future.wait([
        _repository.getExpenseAnalytics(start, end),
        _repository.getIncomeAnalytics(start, end),
        _repository.getMonthlyTrends(start, end),
        _repository.getGoalAnalytics(),
        _repository.getOverallSummary(start, end),
      ]);

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          expenseBreakdown: results[0] as List<CategorySummary>,
          incomeSources: results[1] as List<CategorySummary>,
          monthlyTrends: results[2] as List<MonthlySummary>,
          goalAnalytics: results[3] as dynamic,
          overallSummary: results[4] as Map<String, double>,
          error: null,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _goalsSub?.cancel();
    _contributionsSub?.cancel();
    super.dispose();
  }
}
