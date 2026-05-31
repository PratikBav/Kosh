import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';

/// Provides the [GoRouter] instance.
///
/// This provider creates and caches the router so it can be accessed
/// throughout the widget tree via `ref.watch(routerProvider)`.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
