import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Toggles the platform's secure-window flag.
///
/// On Android this sets `FLAG_SECURE`, which blocks screenshots and screen
/// recording and replaces the app-switcher thumbnail with a blank surface —
/// without it, account balances stay visible in the recents list after the app
/// is backgrounded.
///
/// iOS has no equivalent flag; the privacy cover drawn on lifecycle changes
/// covers that platform instead. Calls are no-ops where unsupported.
class ScreenSecurityService {
  const ScreenSecurityService();

  static const MethodChannel _channel = MethodChannel('kosh/secure_window');

  bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Applies or clears the secure-window flag.
  ///
  /// Failures are swallowed: this is a hardening measure, and a host that does
  /// not implement the channel should not take the app down.
  Future<void> setSecure(bool enabled) async {
    if (!_isSupported) return;

    try {
      await _channel.invokeMethod<void>('setSecure', {'enabled': enabled});
    } on MissingPluginException {
      // Host build predates the channel; nothing to do.
    } on PlatformException catch (error) {
      debugPrint('Could not set secure window flag: ${error.message}');
    }
  }
}
