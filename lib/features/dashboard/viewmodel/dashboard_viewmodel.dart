import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../database/collections/contribution_collection.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../../../providers/database_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../repository/dashboard_repository.dart';
import 'dashboard_state.dart';

final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  final isar = ref.watch(isarProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return DashboardViewModel(isar, repo);
});

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel(this._isar, this._repository) : super(const DashboardState()) {
    _init();
  }

  final Isar _isar;
  final DashboardRepository _repository;
  
  StreamSubscription<void>? _transactionsSub;
  StreamSubscription<void>? _goalsSub;
  StreamSubscription<void>? _contributionsSub;

  void _init() {
    loadDashboard();
    _setupWatchers();
  }

  void _setupWatchers() {
    // Watch for any changes in the respective collections and reload the dashboard.
    _transactionsSub = _isar.transactionCollections.watchLazy().listen((_) {
      loadDashboard();
    });
    
    _goalsSub = _isar.goalCollections.watchLazy().listen((_) {
      loadDashboard();
    });
    
    _contributionsSub = _isar.contributionCollections.watchLazy().listen((_) {
      loadDashboard();
    });
  }

  Future<void> loadDashboard() async {
    try {
      if (state.summary == null) {
        state = state.copyWith(isLoading: true, error: null);
      }
      
      final summary = await _repository.getDashboardSummary();
      
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          summary: summary,
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

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _goalsSub?.cancel();
    _contributionsSub?.cancel();
    super.dispose();
  }
}
