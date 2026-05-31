import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/router_provider.dart';
import '../providers/theme_provider.dart';

/// Root application widget.
///
/// Uses [ConsumerWidget] so it can read Riverpod providers for
/// the router and theme. Configured as [MaterialApp.router]
/// with Material 3 and the Kosh dark theme.
class KoshApp extends ConsumerWidget {
  const KoshApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Kosh',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}
