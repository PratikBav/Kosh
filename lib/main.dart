import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/kosh_app.dart';
import 'core/errors/error_handler.dart';
import 'core/services/notification_service.dart';
import 'database/isar_service.dart';

/// Application entry point.
///
/// Initializes critical services before the widget tree is built:
/// 1. Global error handlers
/// 2. Flutter bindings
/// 3. Isar database
/// 4. Notification service
/// 5. Wraps [KoshApp] in a [ProviderScope] for Riverpod DI
///
/// Binding initialization and [runApp] both run inside the guarded zone —
/// splitting them across zones makes Flutter throw a zone mismatch on start.
void main() {
  ErrorHandler.initialize();

  ErrorHandler.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await IsarService.initialize();
    await NotificationService().initialize();

    runApp(
      const ProviderScope(
        child: KoshApp(),
      ),
    );
  });
}
