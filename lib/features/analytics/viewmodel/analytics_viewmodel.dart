import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/utils/change_debouncer.dart';
import '../../../../database/collections/contribution_collection.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../../../providers/database_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../repository/analytics_repository.dart';
import 'analytics_state.dart';

final analyticsViewModelProvider =
    StateNotifierProvider<AnalyticsViewModel, AnalyticsState>((ref) {
  final isar = ref.watch(isarProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return AnalyticsViewModel(isar, repo);
});

class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  AnalyticsViewModel(this._isar, this._repository)
      : super(const AnalyticsState()) {
    _init();
  }

  final Isar _isar;
  final AnalyticsRepository _repository;

  final List<StreamSubscription<void>> _subscriptions = [];
  final ChangeDebouncer _debouncer = ChangeDebouncer();

  void _init() {
    loadAnalytics();
    _setupWatchers();
  }

  void _setupWatchers() {
    // All three feed the same report, and one edit commonly touches two of
    // them, so the reload is debounced into a single pass.
    for (final stream in [
      _isar.transactionCollections.watchLazy(),
      _isar.goalCollections.watchLazy(),
      _isar.contributionCollections.watchLazy(),
    ]) {
      _subscriptions.add(
        stream.listen((_) => _debouncer.run(loadAnalytics)),
      );
    }
  }

  void setTimeFilter(TimeFilter filter) {
    if (state.selectedTimeFilter == filter) return;
    state = state.copyWith(selectedTimeFilter: filter);
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      // Only show the spinner on a cold load; a refresh behind existing
      // content should not blank the screen.
      if (!state.hasData) {
        state = state.copyWith(isLoading: true, clearError: true);
      }

      final filter = state.selectedTimeFilter;
      final report = await _repository.getReport(
        filter.startDate,
        filter.endDate,
      );

      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        report: report,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
