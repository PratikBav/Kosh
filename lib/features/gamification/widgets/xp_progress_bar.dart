import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.targetXp,
    this.height = 12.0,
  });

  final int currentXp;
  final int targetXp;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pct = targetXp > 0 ? (currentXp / targetXp).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: pct,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
