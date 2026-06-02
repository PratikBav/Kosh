import 'package:isar/isar.dart';

part 'achievement_collection.g.dart';

@collection
class AchievementCollection {
  Id id = Isar.autoIncrement;

  late String title;
  
  late String description;
  
  late String icon;
  
  late int xpReward;
  
  bool isUnlocked = false;
  
  DateTime? unlockedAt;
  
  /// Unique key to identify the achievement logic (e.g. "first_step", "goal_setter")
  @Index(unique: true)
  late String key;
}
