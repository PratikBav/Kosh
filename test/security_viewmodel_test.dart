import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kosh/core/services/pin_service.dart';
import 'package:kosh/core/services/screen_security_service.dart';
import 'package:kosh/core/services/security_service.dart';
import 'package:kosh/database/collections/achievement_collection.dart';
import 'package:kosh/database/collections/app_settings_collection.dart';
import 'package:kosh/database/collections/contribution_collection.dart';
import 'package:kosh/database/collections/goal_collection.dart';
import 'package:kosh/database/collections/security_settings_collection.dart';
import 'package:kosh/database/collections/streak_collection.dart';
import 'package:kosh/database/collections/transaction_collection.dart';
import 'package:kosh/database/collections/user_progress_collection.dart';
import 'package:kosh/database/collections/vision_item_collection.dart';
import 'package:kosh/database/collections/xp_record_collection.dart';
import 'package:kosh/features/security/repository/security_repository.dart';
import 'package:kosh/features/security/viewmodel/security_viewmodel.dart';

import 'pin_service_test.dart' show FakeKeyValueStore;

/// Reports no biometric hardware, which is the state the PIN path must cover.
class NoBiometricsSecurityService extends SecurityService {
  @override
  Future<bool> canUseBiometrics() async => false;

  @override
  Future<bool> authenticateDevice(String reason) async => false;
}

/// The real service would reach for a platform channel that tests do not have.
class NoopScreenSecurityService implements ScreenSecurityService {
  @override
  Future<void> setSecure(bool enabled) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;
  late FakeKeyValueStore store;
  late PinService pinService;
  late SecurityViewModel viewModel;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kosh_security_test');
    isar = await Isar.open(
      [
        TransactionCollectionSchema,
        GoalCollectionSchema,
        ContributionCollectionSchema,
        AchievementCollectionSchema,
        XpRecordCollectionSchema,
        StreakCollectionSchema,
        UserProgressCollectionSchema,
        AppSettingsCollectionSchema,
        SecuritySettingsCollectionSchema,
        VisionItemCollectionSchema,
      ],
      directory: tempDir.path,
      name: 'kosh_security_test',
      inspector: false,
    );

    store = FakeKeyValueStore();
    pinService = PinService(store, iterations: 1000);
    viewModel = SecurityViewModel(
      SecurityRepository(
        isar: isar,
        securityService: NoBiometricsSecurityService(),
      ),
      pinService,
      NoopScreenSecurityService(),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await isar.close(deleteFromDisk: true);
    // Windows can still hold a handle briefly after close; the database itself
    // is already gone, so a failure to remove the empty directory is noise.
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } on FileSystemException {
      // Left for the OS to reap.
    }
  });

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  group('PIN lifecycle', () {
    test('setPin rejects a weak PIN and stores nothing', () async {
      expect(await viewModel.setPin('1111'), contains('repeated digit'));
      expect(await pinService.isPinSet(), isFalse);
    });

    test('app lock cannot be enabled without a PIN', () async {
      expect(await viewModel.setAppLockEnabled(true), isFalse);

      final settings =
          await isar.securitySettingsCollections.get(1) ??
              SecuritySettingsCollection();
      expect(settings.isAppLockEnabled, isFalse);
    });

    test('app lock turns on once a PIN exists', () async {
      expect(await viewModel.setPin('4917'), isNull);
      expect(await viewModel.setAppLockEnabled(true), isTrue);

      final settings = await isar.securitySettingsCollections.get(1);
      expect(settings!.isAppLockEnabled, isTrue);
    });

    test('removePin requires the current PIN and disables app lock', () async {
      await viewModel.setPin('4917');
      await viewModel.setAppLockEnabled(true);

      expect(await viewModel.removePin('0000'), isFalse);
      expect(await pinService.isPinSet(), isTrue);

      expect(await viewModel.removePin('4917'), isTrue);
      expect(await pinService.isPinSet(), isFalse);

      final settings = await isar.securitySettingsCollections.get(1);
      expect(settings!.isAppLockEnabled, isFalse);
    });

    test('changePin refuses when the current PIN is wrong', () async {
      await viewModel.setPin('4917');

      expect(
        await viewModel.changePin(currentPin: '0000', newPin: '8253'),
        contains('not your current PIN'),
      );
      expect(await pinService.verifyPin('4917'), isTrue);

      expect(
        await viewModel.changePin(currentPin: '4917', newPin: '8253'),
        isNull,
      );
      expect(await pinService.verifyPin('8253'), isTrue);
    });
  });

  group('brute force throttling', () {
    test('warns with a countdown, then locks out after five failures',
        () async {
      await viewModel.setPin('4917');

      // Failures 1-4 are refused with a remaining-attempts warning.
      for (var attempt = 1; attempt <= 4; attempt++) {
        final outcome = await viewModel.submitPin('0000');
        expect(outcome.isAccepted, isFalse);
        expect(outcome.isLockedOut, isFalse,
            reason: 'attempt $attempt should not lock out yet');
        expect(outcome.message, contains('${5 - attempt} attempt'));
      }

      // The fifth trips the lockout.
      final locked = await viewModel.submitPin('0000');
      expect(locked.isAccepted, isFalse);
      expect(locked.isLockedOut, isTrue);
      expect(locked.lockoutRemaining, const Duration(seconds: 30));

      // While locked out, even the correct PIN is refused.
      final duringLockout = await viewModel.submitPin('4917');
      expect(duringLockout.isAccepted, isFalse);
      expect(duringLockout.isLockedOut, isTrue);
    });

    test('lockout escalates and is capped at fifteen minutes', () async {
      await viewModel.setPin('4917');

      Future<Duration?> failOnceIgnoringLockout() async {
        // Clear the standing lockout so the next failure is actually counted.
        final settings = await isar.securitySettingsCollections.get(1);
        if (settings != null) {
          settings.pinLockoutUntil = null;
          await isar.writeTxn(
            () => isar.securitySettingsCollections.put(settings),
          );
        }
        final outcome = await viewModel.submitPin('0000');
        return outcome.lockoutRemaining;
      }

      for (var i = 0; i < 4; i++) {
        await failOnceIgnoringLockout();
      }

      expect(await failOnceIgnoringLockout(), const Duration(seconds: 30));
      expect(await failOnceIgnoringLockout(), const Duration(seconds: 60));
      expect(await failOnceIgnoringLockout(), const Duration(seconds: 120));
      expect(await failOnceIgnoringLockout(), const Duration(seconds: 240));
      expect(await failOnceIgnoringLockout(), const Duration(seconds: 480));

      // Capped rather than doubling past the maximum.
      expect(await failOnceIgnoringLockout(), const Duration(minutes: 15));
      expect(await failOnceIgnoringLockout(), const Duration(minutes: 15));
    });

    test('a correct PIN clears the failure count', () async {
      await viewModel.setPin('4917');

      await viewModel.submitPin('0000');
      await viewModel.submitPin('0000');

      expect((await viewModel.submitPin('4917')).isAccepted, isTrue);

      final settings = await isar.securitySettingsCollections.get(1);
      expect(settings!.failedPinAttempts, 0);
      expect(settings.pinLockoutUntil, isNull);

      // The counter restarts, so the next failure reports four left.
      final next = await viewModel.submitPin('0000');
      expect(next.message, contains('4 attempts left'));
    });
  });

  group('auto lock', () {
    test('does not lock when app lock is off', () async {
      await viewModel.checkAutoLock();
      expect(viewModel.state.isLocked, isFalse);
    });

    test('locks immediately when the timeout is set to -1', () async {
      await viewModel.setPin('4917');
      await viewModel.setAppLockEnabled(true);
      await viewModel.setAutoLockDuration(-1);
      await settle();

      await viewModel.checkAutoLock();
      expect(viewModel.state.isLocked, isTrue);
    });

    test('never locks when the timeout is set to 0', () async {
      await viewModel.setPin('4917');
      await viewModel.setAppLockEnabled(true);
      await viewModel.setAutoLockDuration(0);
      await settle();

      await viewModel.checkAutoLock();
      expect(viewModel.state.isLocked, isFalse);
    });

    test('locks once the elapsed timeout has passed', () async {
      await viewModel.setPin('4917');
      await viewModel.setAppLockEnabled(true);
      await viewModel.setAutoLockDuration(60);
      await settle();

      // Still inside the window.
      await viewModel.checkAutoLock();
      expect(viewModel.state.isLocked, isFalse);

      // Backdate the last unlock beyond the timeout.
      final settings = await isar.securitySettingsCollections.get(1);
      settings!.lastUnlockedAt =
          DateTime.now().subtract(const Duration(seconds: 61));
      await isar.writeTxn(
        () => isar.securitySettingsCollections.put(settings),
      );

      await viewModel.checkAutoLock();
      expect(viewModel.state.isLocked, isTrue);
    });

    test('a cold start locks even when the timeout is Never', () async {
      await viewModel.setPin('4917');
      await viewModel.setAppLockEnabled(true);
      await viewModel.setAutoLockDuration(0);
      await settle();

      // Stand in for a fresh launch against the same database. The timeout
      // governs a backgrounded session, not whether a new launch is protected.
      final relaunched = SecurityViewModel(
        SecurityRepository(
          isar: isar,
          securityService: NoBiometricsSecurityService(),
        ),
        pinService,
        NoopScreenSecurityService(),
      );
      addTearDown(relaunched.dispose);
      await settle();

      expect(relaunched.state.isLocked, isTrue);
    });

    test('a cold start stays open when app lock is off', () async {
      final relaunched = SecurityViewModel(
        SecurityRepository(
          isar: isar,
          securityService: NoBiometricsSecurityService(),
        ),
        pinService,
        NoopScreenSecurityService(),
      );
      addTearDown(relaunched.dispose);
      await settle();

      expect(relaunched.state.isLocked, isFalse);
    });

    test('an unlock releases the lock and records the time', () async {
      await viewModel.setPin('4917');
      await viewModel.setAppLockEnabled(true);
      await viewModel.setAutoLockDuration(-1);
      await settle();

      await viewModel.checkAutoLock();
      expect(viewModel.state.isLocked, isTrue);

      await viewModel.unlockApp();
      expect(viewModel.state.isLocked, isFalse);

      final settings = await isar.securitySettingsCollections.get(1);
      expect(settings!.lastUnlockedAt, isNotNull);
    });
  });
}
