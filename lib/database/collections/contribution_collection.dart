import 'package:isar/isar.dart';

part 'contribution_collection.g.dart';

/// Database entity representing a monetary contribution to a specific goal.
@collection
class ContributionCollection {
  Id id = Isar.autoIncrement;

  @Index()
  late int goalId;
  
  late double amount;
  
  String? note;
  
  late DateTime date;
  
  late DateTime createdAt;
}
