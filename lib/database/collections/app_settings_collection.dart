import 'package:isar/isar.dart';

part 'app_settings_collection.g.dart';

@collection
class AppSettingsCollection {
  Id id = 1;

  bool isAchievementSeeded = false;
  bool hasCompletedOnboarding = false;
  
  String appVersion = '1.0.0';

  int? accentColorIndex;
  int? customAccentColorValue;
}
