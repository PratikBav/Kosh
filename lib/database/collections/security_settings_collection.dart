import 'package:isar/isar.dart';

part 'security_settings_collection.g.dart';

@collection
class SecuritySettingsCollection {
  /// Singleton row. Pinned to 1 so repeated reads can never create a second
  /// settings record that shadows the real one.
  Id id = 1;

  bool isAppLockEnabled = false;

  /// Whether biometric unlock is offered in addition to the PIN.
  ///
  /// The PIN is the foundation — it always works. Biometrics are a
  /// convenience layer that the user can turn off, and that silently stays
  /// unavailable on devices with nothing enrolled.
  bool isBiometricEnabled = false;

  /// Blocks screenshots and hides the app-switcher preview (Android
  /// `FLAG_SECURE`). On by default for a finance app.
  bool isScreenSecurityEnabled = true;

  /// In seconds. -1 means immediately, 0 means never.
  int autoLockDuration = 0;

  DateTime? lastUnlockedAt;

  /// Consecutive incorrect PIN entries. Reset on a successful unlock.
  int failedPinAttempts = 0;

  /// While set and in the future, PIN entry is refused outright.
  DateTime? pinLockoutUntil;
}
