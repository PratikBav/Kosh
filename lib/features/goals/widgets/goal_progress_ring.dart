import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// A futuristic circular progress ring for goals.
class GoalProgressRing extends StatelessWidget {
  const GoalProgressRing({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 60.0,
    this.strokeWidth = 6.0,
  });

  final double percentage; // 0.0 to 100.0
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percentage.clamp(0.0, 100.0);
    final value = clampedPercent / 100.0;
    
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            color: AppColors.surfaceLight,
          ),
          // Glow effect underneath (only if progress > 0)
          if (value > 0)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .fade(duration: 1.seconds, begin: 0.5, end: 1.0),
          // Actual progress ring
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            color: color,
            strokeCap: StrokeCap.round,
            backgroundColor: Colors.transparent,
          )
          .animate()
          .custom(
            duration: 1.5.seconds,
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return CircularProgressIndicator(
                value: value * val, // Animate from 0 to target value
                strokeWidth: strokeWidth,
                color: color,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.transparent,
              );
            }
          ),
          // Center Text
          Text(
            '${clampedPercent.toInt()}%',
            style: AppTextStyles.label.copyWith(
              color: value >= 1.0 ? color : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
