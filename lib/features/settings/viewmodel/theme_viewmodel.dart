import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../database/collections/app_settings_collection.dart';
import '../../../providers/database_providers.dart';
import 'package:isar/isar.dart';

final themeViewModelProvider = StateNotifierProvider<ThemeViewModel, Color>((ref) {
  final isar = ref.watch(isarProvider);
  return ThemeViewModel(isar);
});

class ThemeViewModel extends StateNotifier<Color> {
  final Isar _isar;

  ThemeViewModel(this._isar) : super(AppColors.primary) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _isar.appSettingsCollections.get(1);
    if (settings != null) {
      if (settings.customAccentColorValue != null) {
        final color = Color(settings.customAccentColorValue!);
        AppColors.setCustomAccentColor(color);
        state = color;
      } else if (settings.accentColorIndex != null) {
        final accent = AppAccentColor.values[settings.accentColorIndex!];
        AppColors.setAccentColor(accent);
        state = AppColors.primary;
      }
    }
  }

  Future<void> setCustomColor(Color color) async {
    AppColors.setCustomAccentColor(color);
    state = color;
    
    await _isar.writeTxn(() async {
      var settings = await _isar.appSettingsCollections.get(1) ?? AppSettingsCollection();
      // Use deprecated .value for older Flutter or just .value since we don't know the exact SDK.
      // Wait, the warning said "use toARGB32()".
      settings.customAccentColorValue = color.toARGB32();
      settings.accentColorIndex = null;
      await _isar.appSettingsCollections.put(settings);
    });
  }

  Future<void> setAccentColor(AppAccentColor accent) async {
    AppColors.setAccentColor(accent);
    state = AppColors.primary;

    await _isar.writeTxn(() async {
      var settings = await _isar.appSettingsCollections.get(1) ?? AppSettingsCollection();
      settings.accentColorIndex = accent.index;
      settings.customAccentColorValue = null;
      await _isar.appSettingsCollections.put(settings);
    });
  }
}
