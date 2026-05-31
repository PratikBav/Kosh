import 'package:local_auth/local_auth.dart';

/// Manages biometric authentication (fingerprint, face).
///
/// Wraps the [LocalAuthentication] plugin. Call [isAvailable] to
/// check device support before attempting [authenticate].
class BiometricService {
  BiometricService();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks whether biometric authentication is available on this device.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Returns the list of available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Prompts the user for biometric authentication.
  ///
  /// Returns `true` if authentication succeeds.
  Future<bool> authenticate({
    String reason = 'Please authenticate to access Kosh',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow PIN/pattern fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
