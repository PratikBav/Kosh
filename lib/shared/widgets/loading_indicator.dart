import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Themed loading indicator for the Kosh app.
///
/// Centers a circular progress indicator with the primary accent color.
/// Optionally displays a message below the spinner.
///
/// ```dart
/// const LoadingIndicator(message: 'Loading transactions...')
/// ```
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 36,
    this.strokeWidth = 3,
  });

  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: color ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
