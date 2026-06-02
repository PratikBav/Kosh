import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/collections/security_settings_collection.dart';
import '../../../../providers/repository_providers.dart';
import '../repository/security_repository.dart';
import 'security_state.dart';

final securityViewModelProvider = StateNotifierProvider<SecurityViewModel, SecurityState>((ref) {
  final repo = ref.watch(securityRepositoryProvider);
  return SecurityViewModel(repo);
});

class SecurityViewModel extends StateNotifier<SecurityState> {
  final SecurityRepository _repository;
  StreamSubscription<void>? _settingsSub;

  SecurityViewModel(this._repository) : super(const SecurityState()) {
    _init();
  }

  void _init() {
    _loadSettings();
    _setupWatchers();
  }

  void _setupWatchers() {
    _settingsSub = _repository.isar.securitySettingsCollections.watchLazy().listen((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      if (mounted) {
        state = state.copyWith(isLoading: false, settings: settings);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  // --- App Lock Management ---

  Future<bool> toggleAppLock(bool enable) async {
    final settings = await _repository.getSettings();
    if (enable) {
      final canUse = await _repository.securityService.canUseBiometrics();
      if (!canUse) return false;

      // Ask for auth to enable
      final authenticated = await _repository.securityService.authenticateDevice('Authenticate to enable App Lock');
      if (authenticated) {
        settings.isAppLockEnabled = true;
        await _repository.updateSettings(settings);
        return true;
      }
      return false;
    } else {
      // Ask for auth to disable
      final authenticated = await _repository.securityService.authenticateDevice('Authenticate to disable App Lock');
      if (authenticated) {
        settings.isAppLockEnabled = false;
        await _repository.updateSettings(settings);
        return true;
      }
      return false;
    }
  }

  Future<bool> authenticateDevice(String reason) async {
    return await _repository.securityService.authenticateDevice(reason);
  }

  // --- Auto Lock Configuration ---

  Future<void> setAutoLockDuration(int durationInSeconds) async {
    final settings = await _repository.getSettings();
    settings.autoLockDuration = durationInSeconds;
    await _repository.updateSettings(settings);
  }

  // --- App Lock State ---

  void lockApp() {
    if (state.settings?.isAppLockEnabled == true) {
      state = state.copyWith(isLocked: true);
    }
  }

  Future<void> unlockApp() async {
    state = state.copyWith(isLocked: false);
    await _repository.updateLastUnlockedAt(DateTime.now());
  }

  Future<void> checkAutoLock() async {
    final settings = await _repository.getSettings();
    if (!settings.isAppLockEnabled || settings.autoLockDuration == 0) return;

    if (settings.autoLockDuration == -1) {
      lockApp();
      return;
    }

    if (settings.lastUnlockedAt != null) {
      final elapsed = DateTime.now().difference(settings.lastUnlockedAt!).inSeconds;
      if (elapsed >= settings.autoLockDuration) {
        lockApp();
      }
    } else {
      lockApp();
    }
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }
}
