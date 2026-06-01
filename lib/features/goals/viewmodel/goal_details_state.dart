import 'package:flutter/foundation.dart';

import '../../../../database/collections/contribution_collection.dart';
import '../../../../database/collections/goal_collection.dart';

/// State for a specific goal's details screen.
@immutable
class GoalDetailsState {
  const GoalDetailsState({
    this.goal,
    this.contributions = const [],
    this.isLoading = true,
    this.error,
  });

  final GoalCollection? goal;
  final List<ContributionCollection> contributions;
  final bool isLoading;
  final String? error;

  GoalDetailsState copyWith({
    GoalCollection? goal,
    List<ContributionCollection>? contributions,
    bool? isLoading,
    String? error,
  }) {
    return GoalDetailsState(
      goal: goal ?? this.goal,
      contributions: contributions ?? this.contributions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
