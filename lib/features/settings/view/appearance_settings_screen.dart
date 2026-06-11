import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../viewmodel/theme_viewmodel.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  void _showColorPicker(BuildContext context, WidgetRef ref, Color currentColor) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Pick a Color', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            colorPickerWidth: 300.0,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              ref.read(themeViewModelProvider.notifier).setCustomColor(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeColor = ref.watch(themeViewModelProvider);

    final presetColors = {
      AppAccentColor.purple: const Color(0xFFA855F7),
      AppAccentColor.emerald: const Color(0xFF10B981),
      AppAccentColor.rose: const Color(0xFFF43F5E),
      AppAccentColor.cyan: const Color(0xFF06B6D4),
      AppAccentColor.gold: const Color(0xFFF59E0B),
    };

    final isCustomColorActive = !presetColors.values.contains(activeColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Accent Color',
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Choose your Wealth OS accent color. This changes the glowing accents across the app.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              ...AppAccentColor.values.map((colorEnum) {
                final previewColor = presetColors[colorEnum]!;
                final isSelected = activeColor == previewColor;
                final label = colorEnum.name[0].toUpperCase() + colorEnum.name.substring(1);

                return _buildColorOption(
                  previewColor: previewColor,
                  label: label,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(themeViewModelProvider.notifier).setAccentColor(colorEnum);
                  },
                );
              }),
              _buildColorOption(
                previewColor: isCustomColorActive ? activeColor : Colors.white,
                label: 'Custom',
                isSelected: isCustomColorActive,
                isCustom: true,
                onTap: () {
                  _showColorPicker(context, ref, activeColor);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption({
    required Color previewColor,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCustom ? Colors.transparent : previewColor.withValues(alpha: 0.15),
              gradient: isCustom && !isSelected 
                  ? const SweepGradient(colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red])
                  : null,
              border: Border.all(
                color: isSelected ? previewColor : AppColors.surfaceBorder,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: previewColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCustom && !isSelected ? Colors.transparent : previewColor,
                ),
                child: isCustom && !isSelected
                    ? const Icon(Icons.colorize_rounded, color: Colors.white)
                    : isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? previewColor : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
