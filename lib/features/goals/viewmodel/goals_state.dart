import 'package:flutter/foundation.dart';

import '../../../../database/collections/goal_collection.dart';

/// State object for the Goals feature.
@immutable
class GoalsState {
  const GoalsState({
    this.goals = const [],
    this.isLoading = true,
    this.error,
  });

  final List<GoalCollection> goals;
  final bool isLoading;
  final String? error;

  /// Derived total target amount across all goals.
  double get totalTargetAmount => goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

  /// Derived total saved amount across all goals.
  double get totalSavedAmount => goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);

  /// Number of active (uncompleted) goals.
  int get activeGoalsCount => goals.where((g) => !g.isCompleted).length;

  /// Number of completed goals.
  int get completedGoalsCount => goals.where((g) => g.isCompleted).length;

  GoalsState copyWith({
    List<GoalCollection>? goals,
    bool? isLoading,
    String? error,
  }) {
    return GoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
