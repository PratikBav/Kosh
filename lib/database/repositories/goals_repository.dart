import 'package:isar/isar.dart';

import '../collections/contribution_collection.dart';
import '../collections/goal_collection.dart';

/// Repository for handling Goals and their Contributions data operations.
class GoalsRepository {
  const GoalsRepository(this._isar);

  final Isar _isar;


  /// Adds a new goal.
  Future<void> createGoal(GoalCollection goal) async {
    await _isar.writeTxn(() async {
      await _isar.goalCollections.put(goal);
    });
  }

  /// Updates an existing goal.
  Future<void> updateGoal(GoalCollection goal) async {
    await _isar.writeTxn(() async {
      await _isar.goalCollections.put(goal);
    });
  }

  /// Deletes a goal and all its contributions.
  Future<void> deleteGoal(int goalId) async {
    await _isar.writeTxn(() async {
      // 1. Delete associated contributions
      await _isar.contributionCollections.filter().goalIdEqualTo(goalId).deleteAll();
      // 2. Delete the goal itself
      await _isar.goalCollections.delete(goalId);
    });
  }

  /// Gets all goals ordered by creation date descending.
  Future<List<GoalCollection>> getAllGoals() async {
    return await _isar.goalCollections
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Gets a specific goal by ID.
  Future<GoalCollection?> getGoalById(int id) async {
    return await _isar.goalCollections.get(id);
  }

  /// Marks a goal as completed.
  Future<void> markGoalCompleted(int id, bool isCompleted) async {
    await _isar.writeTxn(() async {
      final goal = await _isar.goalCollections.get(id);
      if (goal != null) {
        goal.isCompleted = isCompleted;
        goal.updatedAt = DateTime.now();
        await _isar.goalCollections.put(goal);
      }
    });
  }


  /// Adds a new contribution to a goal and updates the goal's currentAmount.
  Future<void> addContribution(ContributionCollection contribution) async {
    await _isar.writeTxn(() async {
      // 1. Save contribution
      await _isar.contributionCollections.put(contribution);

      // 2. Update the parent goal's current amount
      final goal = await _isar.goalCollections.get(contribution.goalId);
      if (goal != null) {
        goal.currentAmount += contribution.amount;
        
        // 3. Auto-complete goal if target reached
        if (goal.currentAmount >= goal.targetAmount) {
          goal.isCompleted = true;
        }
        
        goal.updatedAt = DateTime.now();
        await _isar.goalCollections.put(goal);
      }
    });
  }

  /// Gets all contributions for a specific goal, ordered by date descending.
  Future<List<ContributionCollection>> getContributionsForGoal(int goalId) async {
    return await _isar.contributionCollections
        .filter()
        .goalIdEqualTo(goalId)
        .sortByDateDesc()
        .findAll();
  }
}
