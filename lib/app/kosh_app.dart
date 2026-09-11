import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/view/app_lock_screen.dart';
import '../features/security/viewmodel/security_viewmodel.dart';
import '../providers/router_provider.dart';
import '../providers/theme_provider.dart';
import 'theme/app_colors.dart';

class KoshApp extends ConsumerStatefulWidget {
  const KoshApp({super.key});

  @override
  ConsumerState<KoshApp> createState() => _KoshAppState();
}

class _KoshAppState extends ConsumerState<KoshApp> with WidgetsBindingObserver {
  /// True whenever the app is not in the foreground, so the screenshot the OS
  /// takes for the app switcher captures the privacy cover instead of the
  /// user's balances.
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(securityViewModelProvider.notifier).checkAutoLock();
        setState(() => _isObscured = false);

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Raised synchronously, before the OS captures its snapshot.
        setState(() => _isObscured = true);
        ref.read(securityViewModelProvider.notifier).onAppPaused();

      case AppLifecycleState.detached:
        break;
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
            ?child,

            // Settings are read asynchronously, so without this the real
            // content would render for a frame or two before a lock applied.
            if (securityState.isResolvingLock)
              const _PrivacyCover(showBranding: true)
            else if (securityState.isLocked)
              const AppLockScreen()
            else if (_isObscured)
              const _PrivacyCover(),
          ],
        );
      },
    );
  }
}

/// Opaque panel that hides app content.
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover({this.showBranding = false});

  final bool showBranding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: showBranding
            ? Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: AppColors.primary,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
