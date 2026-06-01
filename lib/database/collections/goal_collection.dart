import 'package:isar/isar.dart';

import '../../features/goals/models/goal_category.dart';
import '../../features/goals/models/goal_priority.dart';

part 'goal_collection.g.dart';

/// Database entity for a financial goal.
@collection
class GoalCollection {
  Id id = Isar.autoIncrement;

  late String title;
  
  String? description;
  
  late double targetAmount;
  
  double currentAmount = 0.0;

  @Index()
  late DateTime deadline;

  @Enumerated(EnumType.name)
  late GoalCategory category;

  @Enumerated(EnumType.name)
  late GoalPriority priority;

  late DateTime createdAt;
  
  late DateTime updatedAt;

  @Index()
  bool isCompleted = false;
}
