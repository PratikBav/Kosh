import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/kosh_app.dart';
import 'database/isar_service.dart';
import 'core/services/notification_service.dart';

/// Application entry point.
///
/// Initializes critical services before the widget tree is built:
/// 1. Flutter bindings
/// 2. Isar database
/// 3. Notification service
/// 4. Wraps [KoshApp] in a [ProviderScope] for Riverpod DI
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar database
  await IsarService.initialize();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: KoshApp(),
    ),
  );
}
