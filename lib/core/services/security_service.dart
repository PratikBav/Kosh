import 'package:local_auth/local_auth.dart';

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // --- Device Authentication ---

  Future<bool> canUseBiometrics() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return canCheck || isDeviceSupported;
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
