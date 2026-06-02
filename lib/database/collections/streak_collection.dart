import 'package:isar/isar.dart';

part 'streak_collection.g.dart';

@collection
class StreakCollection {
  /// We only ever have one streak record per user.
  Id id = 1;

  int currentStreak = 0;
  
  int longestStreak = 0;
  
  DateTime? lastActivityDate;
}
