import '../../../../database/collections/goal_collection.dart';

class GoalAnalytics {
  GoalAnalytics({
    required this.totalGoalTarget,
    required this.totalSaved,
    required this.activeGoalsCount,
    required this.completedGoalsCount,
    required this.goals,
  });

  final double totalGoalTarget;
  final double totalSaved;
  final int activeGoalsCount;
  final int completedGoalsCount;
  final List<GoalCollection> goals;

  double get overallCompletionPercentage {
    if (totalGoalTarget <= 0) return 0;
    return (totalSaved / totalGoalTarget) * 100;
  }
}
