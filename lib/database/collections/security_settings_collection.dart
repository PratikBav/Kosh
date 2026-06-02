import 'package:isar/isar.dart';

part 'security_settings_collection.g.dart';

@collection
class SecuritySettingsCollection {
  Id id = Isar.autoIncrement;

  bool isAppLockEnabled = false;
  
  /// In seconds. -1 means immediately, 0 means never.
  int autoLockDuration = 0;
  
  DateTime? lastUnlockedAt;
}
