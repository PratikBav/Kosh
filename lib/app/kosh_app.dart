import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/view/app_lock_screen.dart';
import '../features/security/viewmodel/security_viewmodel.dart';
import '../providers/router_provider.dart';
import '../providers/theme_provider.dart';

class KoshApp extends ConsumerStatefulWidget {
  const KoshApp({super.key});

  @override
  ConsumerState<KoshApp> createState() => _KoshAppState();
}

class _KoshAppState extends ConsumerState<KoshApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(securityViewModelProvider.notifier).checkAutoLock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(securityViewModelProvider.notifier).checkAutoLock();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Just record timestamp when pausing is handled implicitly in checkAutoLock which locks based on lastUnlockedAt
      // Actually we need to lock if timeout is exceeded, but here we can just lock immediately if timeout is -1
      // For simplicity, we just rely on checkAutoLock when resumed.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider);
    final securityState = ref.watch(securityViewModelProvider);

    return MaterialApp.router(
      title: 'Kosh',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            // ignore: use_null_aware_elements
            if (child != null) child,
            if (securityState.isLocked) const AppLockScreen(),
          ],
        );
      },
    );
  }
}
