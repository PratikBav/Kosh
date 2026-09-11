import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import '../core/services/biometric_service.dart';
import '../core/services/pin_service.dart';
import '../core/services/screen_security_service.dart';
import '../core/services/secure_storage_service.dart';

/// Provides the [NotificationService] singleton.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provides the [BiometricService] singleton.
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Provides the [SecureStorageService] singleton.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provides the [PinService], backed by encrypted platform storage.
final pinServiceProvider = Provider<PinService>((ref) {
  return PinService(ref.watch(secureStorageServiceProvider));
});

/// Provides the [ScreenSecurityService] singleton.
final screenSecurityServiceProvider = Provider<ScreenSecurityService>((ref) {
  return const ScreenSecurityService();
});
