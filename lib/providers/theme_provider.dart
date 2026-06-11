import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/app_theme.dart';

import '../features/settings/viewmodel/theme_viewmodel.dart';

/// Provides the current [ThemeData].
///
/// Returns the dark theme, dynamically updating when the user changes
/// their accent color.
final themeProvider = Provider((ref) {
  ref.watch(themeViewModelProvider);
  return AppTheme.darkTheme;
});
