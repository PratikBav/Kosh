import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import '../core/services/biometric_service.dart';
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
