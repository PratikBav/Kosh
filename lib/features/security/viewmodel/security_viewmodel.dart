import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/collections/security_settings_collection.dart';
import '../../../../core/services/pin_service.dart';
import '../../../../core/services/screen_security_service.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/service_providers.dart';
import '../repository/security_repository.dart';
import 'security_state.dart';

final securityViewModelProvider =
    StateNotifierProvider<SecurityViewModel, SecurityState>((ref) {
  return SecurityViewModel(
    ref.watch(securityRepositoryProvider),
    ref.watch(pinServiceProvider),
    ref.watch(screenSecurityServiceProvider),
  );
});

class SecurityViewModel extends StateNotifier<SecurityState> {
  SecurityViewModel(
    this._repository,
    this._pinService,
    this._screenSecurity,
  ) : super(const SecurityState()) {
    _init();
  }

  final SecurityRepository _repository;
  final PinService _pinService;
  final ScreenSecurityService _screenSecurity;

  StreamSubscription<void>? _settingsSub;

  /// Guards the one-time startup lock decision in [_loadSettings], so later
  /// settings changes cannot re-lock an app the user has already opened.
  bool _hasResolvedInitialLock = false;

  /// Failures tolerated before entry is throttled.
  static const int _attemptsBeforeLockout = 5;

  /// First lockout length; each further failure doubles it up to [_maxLockout].
  static const Duration _baseLockout = Duration(seconds: 30);
  static const Duration _maxLockout = Duration(minutes: 15);

  void _init() {
    _loadSettings();
    _setupWatchers();
  }

  void _setupWatchers() {
    _settingsSub = _repository.isar.securitySettingsCollections
        .watchLazy()
        .listen((_) => _loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      final isPinSet = await _pinService.isPinSet();
      final isBiometricAvailable =
          await _repository.securityService.canUseBiometrics();

      if (!mounted) return;

      // App lock without a PIN is unenforceable, so treat it as off. This also
      // recovers installs from the biometric-only build that enabled lock on a
      // device whose biometrics were later removed.
      final lockIsUsable = settings.isAppLockEnabled && isPinSet;

      // The very first load decides the lock itself rather than waiting for a
      // separate checkAutoLock round trip — otherwise isLoading clears, the
      // cover lifts, and account data is on screen before the lock arrives.
      //
      // A cold start always locks. autoLockDuration governs how long a
      // backgrounded session stays open, not whether a fresh launch is
      // protected; without this, pairing app lock with a "Never" timeout would
      // leave the app permanently unlocked.
      final isLocked =
          _hasResolvedInitialLock ? state.isLocked && lockIsUsable : lockIsUsable;
      _hasResolvedInitialLock = true;

      state = state.copyWith(
        isLoading: false,
        settings: settings,
        isPinSet: isPinSet,
        isBiometricAvailable: isBiometricAvailable,
        isLocked: isLocked,
        clearError: true,
      );

      await _screenSecurity.setSecure(settings.isScreenSecurityEnabled);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // PIN management
  // ---------------------------------------------------------------------------

  /// Sets the first PIN. Returns an error message, or `null` on success.
  Future<String?> setPin(String pin) async {
    final problem = PinService.validatePin(pin);
    if (problem != null) return problem;

    try {
      await _pinService.setPin(pin);
      await _resetFailedAttempts();
      if (mounted) state = state.copyWith(isPinSet: true);
      return null;
    } catch (e) {
      return 'Could not save the PIN. $e';
    }
  }

  /// Replaces an existing PIN. Returns an error message, or `null` on success.
  Future<String?> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (!await _pinService.verifyPin(currentPin)) {
      return 'That is not your current PIN.';
    }
    return setPin(newPin);
  }

  /// Removes the PIN and, with it, app lock.
  Future<bool> removePin(String currentPin) async {
    if (!await _pinService.verifyPin(currentPin)) return false;

    await _pinService.clearPin();

    final settings = await _repository.getSettings();
    settings.isAppLockEnabled = false;
    settings.isBiometricEnabled = false;
    await _repository.updateSettings(settings);

    if (mounted) {
      state = state.copyWith(isPinSet: false, isLocked: false);
    }
    return true;
  }

  /// Checks [pin] against the stored PIN, applying throttling.
  Future<PinAttemptOutcome> submitPin(String pin) async {
    final settings = await _repository.getSettings();

    final remaining = _remainingLockout(settings.pinLockoutUntil);
    if (remaining != null) {
      return PinAttemptOutcome.lockedOut(
        remaining,
        'Too many attempts. Try again in ${_formatDuration(remaining)}.',
      );
    }

    if (await _pinService.verifyPin(pin)) {
      settings.failedPinAttempts = 0;
      settings.pinLockoutUntil = null;
      settings.lastUnlockedAt = DateTime.now();
      await _repository.updateSettings(settings);

      if (mounted) state = state.copyWith(isLocked: false);
      return const PinAttemptOutcome.accepted();
    }

    settings.failedPinAttempts += 1;
    final lockout = _lockoutFor(settings.failedPinAttempts);
    if (lockout > Duration.zero) {
      settings.pinLockoutUntil = DateTime.now().add(lockout);
    }
    await _repository.updateSettings(settings);

    if (lockout > Duration.zero) {
      return PinAttemptOutcome.lockedOut(
        lockout,
        'Too many attempts. Try again in ${_formatDuration(lockout)}.',
      );
    }

    final left = _attemptsBeforeLockout - settings.failedPinAttempts;
    return PinAttemptOutcome.rejected(
      left == 1
          ? 'Incorrect PIN. 1 attempt left.'
          : 'Incorrect PIN. $left attempts left.',
    );
  }

  Future<void> _resetFailedAttempts() async {
    final settings = await _repository.getSettings();
    settings.failedPinAttempts = 0;
    settings.pinLockoutUntil = null;
    await _repository.updateSettings(settings);
  }

  /// Remaining lockout, or `null` if entry is currently allowed.
  Duration? _remainingLockout(DateTime? until) {
    if (until == null) return null;
    final remaining = until.difference(DateTime.now());
    return remaining > Duration.zero ? remaining : null;
  }

  /// Zero until [_attemptsBeforeLockout], then doubling from [_baseLockout].
  static Duration _lockoutFor(int attempts) {
    if (attempts < _attemptsBeforeLockout) return Duration.zero;

    final step = attempts - _attemptsBeforeLockout;
    final seconds = _baseLockout.inSeconds * math.pow(2, step).toInt();
    return Duration(
      seconds: math.min(seconds, _maxLockout.inSeconds),
    );
  }

  static String _formatDuration(Duration duration) {
    if (duration.inMinutes >= 1) {
      final minutes = duration.inMinutes + (duration.inSeconds % 60 > 0 ? 1 : 0);
      return minutes == 1 ? '1 minute' : '$minutes minutes';
    }
    final seconds = math.max(duration.inSeconds, 1);
    return seconds == 1 ? '1 second' : '$seconds seconds';
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  /// Turns app lock on or off. Callers must authenticate the user first.
  ///
  /// Enabling is refused without a PIN, since there would be no way back in.
  Future<bool> setAppLockEnabled(bool enabled) async {
    if (enabled && !await _pinService.isPinSet()) return false;

    final settings = await _repository.getSettings();
    settings.isAppLockEnabled = enabled;
    if (!enabled) settings.isBiometricEnabled = false;
    settings.lastUnlockedAt = DateTime.now();
    await _repository.updateSettings(settings);
    return true;
  }

  /// Enables or disables biometric unlock as a shortcut past the PIN.
  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      if (!await _repository.securityService.canUseBiometrics()) return false;
      final authenticated = await _repository.securityService
          .authenticateDevice('Confirm to enable biometric unlock');
      if (!authenticated) return false;
    }

    final settings = await _repository.getSettings();
    settings.isBiometricEnabled = enabled;
    await _repository.updateSettings(settings);
    return true;
  }

  Future<void> setScreenSecurityEnabled(bool enabled) async {
    final settings = await _repository.getSettings();
    settings.isScreenSecurityEnabled = enabled;
    await _repository.updateSettings(settings);
    await _screenSecurity.setSecure(enabled);
  }

  Future<void> setAutoLockDuration(int durationInSeconds) async {
    final settings = await _repository.getSettings();
    settings.autoLockDuration = durationInSeconds;
    await _repository.updateSettings(settings);
  }

  Future<bool> authenticateDevice(String reason) {
    return _repository.securityService.authenticateDevice(reason);
  }

  // ---------------------------------------------------------------------------
  // Lock lifecycle
  // ---------------------------------------------------------------------------

  /// Attempts a biometric unlock. Returns `false` if it was not available,
  /// not enabled, or refused.
  Future<bool> unlockWithBiometrics() async {
    if (!state.canUseBiometricUnlock) return false;

    final authenticated =
        await _repository.securityService.authenticateDevice('Unlock Kosh');
    if (!authenticated) return false;

    await unlockApp();
    return true;
  }

  void lockApp() {
    if (state.settings?.isAppLockEnabled == true && state.isPinSet) {
      state = state.copyWith(isLocked: true);
    }
  }

  Future<void> unlockApp() async {
    state = state.copyWith(isLocked: false);
    await _resetFailedAttempts();
    await _repository.updateLastUnlockedAt(DateTime.now());
  }

  /// Records the moment the app left the foreground.
  ///
  /// The timestamp is what [checkAutoLock] measures the timeout against, so it
  /// has to be written on the way out rather than only on unlock.
  Future<void> onAppPaused() async {
    if (state.settings?.isAppLockEnabled != true) return;
    if (state.isLocked) return;

    // Lock eagerly when the timeout is "immediately" so the lock is already in
    // place by the time the app is resumed, with no asynchronous gap.
    if (state.settings?.autoLockDuration == -1) {
      lockApp();
    }
  }

  Future<void> checkAutoLock() async {
    final settings = await _repository.getSettings();
    if (!settings.isAppLockEnabled) return;
    if (!await _pinService.isPinSet()) return;
    if (_shouldLockNow(settings)) lockApp();
  }

  /// Whether the auto-lock timeout has elapsed.
  ///
  /// Assumes app lock is enabled and a PIN is set; callers check both.
  /// A duration of 0 means never, -1 means immediately.
  static bool _shouldLockNow(SecuritySettingsCollection settings) {
    if (settings.autoLockDuration == 0) return false;
    if (settings.autoLockDuration == -1) return true;

    final lastUnlocked = settings.lastUnlockedAt;
    if (lastUnlocked == null) return true;

    return DateTime.now().difference(lastUnlocked).inSeconds >=
        settings.autoLockDuration;
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }
}
