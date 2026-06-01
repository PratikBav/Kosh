import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../database/collections/contribution_collection.dart';
import '../../../../database/repositories/goals_repository.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/service_providers.dart';
import 'goal_details_state.dart';
import 'goals_viewmodel.dart';

/// Provider for a specific goal's details, scoped by [goalId].
final goalDetailsViewModelProvider = StateNotifierProvider.family<
    GoalDetailsViewModel, GoalDetailsState, int>((ref, goalId) {
  final repository = ref.watch(goalsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return GoalDetailsViewModel(
    goalId,
    repository,
    notificationService,
    ref, // Used to trigger a refresh on the main goals list
  );
});

/// ViewModel managing a single goal and its contributions.
class GoalDetailsViewModel extends StateNotifier<GoalDetailsState> {
  GoalDetailsViewModel(
    this._goalId,
    this._repository,
    this._notificationService,
    this._ref,
  ) : super(const GoalDetailsState()) {
    loadDetails();
  }

  final int _goalId;
  final GoalsRepository _repository;
  final NotificationService _notificationService;
  final Ref _ref;

  /// Loads the specific goal and its contribution history.
  Future<void> loadDetails() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final goal = await _repository.getGoalById(_goalId);
      final contributions = await _repository.getContributionsForGoal(_goalId);
      state = state.copyWith(
        goal: goal,
        contributions: contributions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException.from(e).message,
      );
    }
  }

  /// Adds a contribution to this goal.
  Future<void> addContribution(ContributionCollection contribution) async {
    try {
      final wasCompleted = state.goal?.isCompleted ?? false;

      await _repository.addContribution(contribution);
      
      // Reload this specific view
      await loadDetails();
      
      // Refresh the main goals view
      _ref.read(goalsViewModelProvider.notifier).loadGoals();

      // Check if newly completed
      final isNowCompleted = state.goal?.isCompleted ?? false;
      if (!wasCompleted && isNowCompleted) {
        _notificationService.showNotification(
          id: _goalId,
          title: 'Goal Completed! 🎉',
          body: 'Congratulations! You reached your goal for ${state.goal?.title}.',
        );
      }
    } catch (e) {
      state = state.copyWith(error: AppException.from(e).message);
      rethrow;
    }
  }

  /// Updates the goal details (e.g. edit title/deadline).
  Future<void> updateGoal() async {
    try {
      if (state.goal == null) return;
      await _repository.updateGoal(state.goal!);
      await loadDetails();
      _ref.read(goalsViewModelProvider.notifier).loadGoals();
    } catch (e) {
      state = state.copyWith(error: AppException.from(e).message);
      rethrow;
    }
  }
}
