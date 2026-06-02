import '../../../../database/collections/security_settings_collection.dart';

class SecurityState {
  final bool isLoading;
  final String? error;
  final SecuritySettingsCollection? settings;
  final bool isLocked;

  const SecurityState({
    this.isLoading = true,
    this.error,
    this.settings,
    this.isLocked = false,
  });

  SecurityState copyWith({
    bool? isLoading,
    String? error,
    SecuritySettingsCollection? settings,
    bool? isLocked,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      settings: settings ?? this.settings,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
