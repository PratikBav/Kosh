import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../database/isar_service.dart';

/// Provides the [Isar] database instance.
///
/// [IsarService.initialize] must be called before this provider is read.
/// This is done in `main()` before `runApp()`.
final isarProvider = Provider<Isar>((ref) {
  return IsarService.instance;
});
