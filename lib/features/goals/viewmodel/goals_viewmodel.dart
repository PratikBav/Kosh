import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../database/repositories/goals_repository.dart';
import '../../../../providers/repository_providers.dart';
import '../../gamification/viewmodel/gamification_viewmodel.dart';
import 'goals_state.dart';

/// Provider for the [GoalsViewModel].
final goalsViewModelProvider =
    StateNotifierProvider<GoalsViewModel, GoalsState>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  final gamification = ref.read(gamificationViewModelProvider.notifier);
  return GoalsViewModel(repository, gamification);
});

/// ViewModel managing the global list of goals.
class GoalsViewModel extends StateNotifier<GoalsState> {
  GoalsViewModel(this._repository, this._gamification) : super(const GoalsState()) {
    loadGoals();
  }

  final GoalsRepository _repository;
  final GamificationViewModel _gamification;

  /// Loads all goals from the database.
  Future<void> loadGoals() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final goals = await _repository.getAllGoals();
      state = state.copyWith(goals: goals, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException.from(e).message,
      );
    }
  }

  /// Creates a new goal.
  Future<void> createGoal(GoalCollection goal) async {
    try {
      await _repository.createGoal(goal);
      await loadGoals();
      await _gamification.logGoalCreated();
    } catch (e) {
      state = state.copyWith(error: AppException.from(e).message);
      rethrow;
    }
  }

  /// Deletes a goal and its contributions.
  Future<void> deleteGoal(int goalId) async {
    try {
      await _repository.deleteGoal(goalId);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(error: AppException.from(e).message);
      rethrow;
    }
  }
}
