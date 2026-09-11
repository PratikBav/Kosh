import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Title above a group of content, with an optional trailing action.
///
/// Used to give the dashboard a consistent rhythm — every section is labelled
/// the same way, so the eye can find the boundaries without hunting.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionPressed,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        if (action != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(action!, style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.primary,
                )),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppSpacing.iconSm,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
