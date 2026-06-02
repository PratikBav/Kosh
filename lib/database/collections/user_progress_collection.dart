import 'package:isar/isar.dart';

part 'user_progress_collection.g.dart';

@collection
class UserProgressCollection {
  /// Only one progress record per user.
  Id id = 1;

  int totalXp = 0;
  
  int currentLevel = 1;
}
