import 'package:isar/isar.dart';
import '../../../../core/services/security_service.dart';
import '../../../../database/collections/security_settings_collection.dart';

class SecurityRepository {
  final Isar isar;
  final SecurityService securityService;

  SecurityRepository({required this.isar, required this.securityService});

  Future<SecuritySettingsCollection> getSettings() async {
    final settings = await isar.securitySettingsCollections.where().findFirst();
    if (settings != null) return settings;

    // Create default if not exists
    final defaultSettings = SecuritySettingsCollection();
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
