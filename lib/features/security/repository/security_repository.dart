import 'package:isar/isar.dart';
import '../../../../core/services/security_service.dart';
import '../../../../database/collections/security_settings_collection.dart';

class SecurityRepository {
  final Isar isar;
  final SecurityService securityService;

  SecurityRepository({required this.isar, required this.securityService});

  /// Id of the singleton settings row.
  static const int _settingsId = 1;

  Future<SecuritySettingsCollection> getSettings() async {
    final settings = await isar.securitySettingsCollections.get(_settingsId);
    if (settings != null) return settings;

    // Create default if not exists
    final defaultSettings = SecuritySettingsCollection()..id = _settingsId;
    await isar.writeTxn(() async {
      await isar.securitySettingsCollections.put(defaultSettings);
    });
    return defaultSettings;
  }

  Future<void> updateSettings(SecuritySettingsCollection settings) async {
    await isar.writeTxn(() async {
      await isar.securitySettingsCollections.put(settings);
    });
  }

  Future<void> updateLastUnlockedAt(DateTime time) async {
    final settings = await getSettings();
    settings.lastUnlockedAt = time;
    await updateSettings(settings);
  }
}
