import '../../../../database/collections/security_settings_collection.dart';

/// Outcome of a PIN entry attempt.
class PinAttemptOutcome {
  const PinAttemptOutcome._({
    required this.isAccepted,
    this.message,
    this.lockoutRemaining,
  });

  const PinAttemptOutcome.accepted() : this._(isAccepted: true);

  const PinAttemptOutcome.rejected(String message)
      : this._(isAccepted: false, message: message);

  const PinAttemptOutcome.lockedOut(Duration remaining, String message)
      : this._(
          isAccepted: false,
          message: message,
          lockoutRemaining: remaining,
        );

  final bool isAccepted;

  /// User-facing explanation when the attempt was refused.
  final String? message;

  /// Non-null while entry is throttled after repeated failures.
  final Duration? lockoutRemaining;

  bool get isLockedOut => lockoutRemaining != null;
}

class SecurityState {
  const SecurityState({
    this.isLoading = true,
    this.error,
    this.settings,
    this.isLocked = false,
    this.isPinSet = false,
    this.isBiometricAvailable = false,
  });

  final bool isLoading;
  final String? error;
  final SecuritySettingsCollection? settings;
  final bool isLocked;

  /// Whether a PIN has been configured. The PIN is the foundation of app
  /// lock — biometrics cannot be enabled without one.
  final bool isPinSet;

  /// Whether this device has usable biometric or device-credential hardware.
  final bool isBiometricAvailable;

  /// Whether biometric unlock should be offered on the lock screen.
  bool get canUseBiometricUnlock =>
      isBiometricAvailable && (settings?.isBiometricEnabled ?? false);

  /// True until the stored settings have been read, so the UI can hold a
  /// cover in place rather than flashing account data before a lock applies.
  bool get isResolvingLock => isLoading;

  SecurityState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    SecuritySettingsCollection? settings,
    bool? isLocked,
    bool? isPinSet,
    bool? isBiometricAvailable,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      settings: settings ?? this.settings,
      isLocked: isLocked ?? this.isLocked,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
    );
  }
}
