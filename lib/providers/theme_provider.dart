import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/app_theme.dart';

/// Provides the current [ThemeData].
///
/// For now this is a simple static provider returning the dark theme.
/// In the future, this could be extended to support theme switching.
final themeProvider = Provider((ref) {
  return AppTheme.darkTheme;
});
