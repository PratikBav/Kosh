import 'package:isar/isar.dart';

part 'security_settings_collection.g.dart';

@collection
class SecuritySettingsCollection {
  /// Singleton row. Pinned to 1 so repeated reads can never create a second
  /// settings record that shadows the real one.
  Id id = 1;

  bool isAppLockEnabled = false;
  
  /// In seconds. -1 means immediately, 0 means never.
  int autoLockDuration = 0;
  
  DateTime? lastUnlockedAt;
}
