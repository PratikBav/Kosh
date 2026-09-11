import 'package:local_auth/local_auth.dart';

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // --- Device Authentication ---

  /// Whether the device can authenticate via biometrics or a device
  /// credential.
  ///
  /// Returns `false` rather than throwing: local_auth can fail on devices with
  /// a missing or misbehaving keyguard, and an unavailable sensor must never
  /// take down the screen asking about it.
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateDevice(String reason) async {
    if (!await canUseBiometrics()) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow fallback to device PIN/Pattern
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
