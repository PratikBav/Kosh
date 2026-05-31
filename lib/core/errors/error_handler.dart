import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_exception.dart';

/// Global error handler for the Kosh application.
///
/// Captures Flutter framework errors and Dart zone errors,
/// logging them for debugging. In production, these could be
/// forwarded to a local error log.
class ErrorHandler {
  ErrorHandler._();

  /// Initializes global error handlers.
  ///
  /// Call once in `main()` before `runApp()`.
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Handle errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  /// Wraps [runApp] in a guarded zone to catch uncaught async errors.
  static Future<void> runGuarded(Future<void> Function() appRunner) async {
    await runZonedGuarded(
      () async => await appRunner(),
      (error, stackTrace) => _logError(error, stackTrace),
    );
  }

  /// Logs an error for debugging.
  static void _logError(Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('═══════════════════════════════════════');
      print('🔴 KOSH ERROR');
      print('Error: $error');
      if (error is AppException) {
        print('Code: ${error.code}');
      }
      if (stackTrace != null) {
        print('Stack: $stackTrace');
      }
      print('═══════════════════════════════════════');
    }
  }
}
