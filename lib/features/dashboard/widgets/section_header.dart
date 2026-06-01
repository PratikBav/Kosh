import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';

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
        Text(title, style: AppTextStyles.title),
        if (action != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(action!),
          ),
      ],
    );
  }
}
