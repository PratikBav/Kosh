import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/cards/kosh_card.dart';

class WealthHealthRing extends StatelessWidget {
  final double score; // 0 to 100

  const WealthHealthRing({super.key, required this.score});

  Color _getScoreColor() {
    if (score <= 30) return AppColors.danger;
    if (score <= 60) return AppColors.warning;
    if (score <= 80) return AppColors.secondary;
    return AppColors.success;
  }

  String _getScoreLabel() {
    if (score <= 30) return 'Needs Attention';
    if (score <= 60) return 'Fair';
    if (score <= 80) return 'Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor();
    
    return KoshCard(
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceLight,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${score.toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Financial Health',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getScoreLabel(),
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
