import 'package:flutter/material.dart';
import 'package:democracy_js/core/theme/app_colors.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.text,
    this.onDelete,
    this.trailing,
  });

  final String text;
  final VoidCallback? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppTextStyles.body)),
          if (trailing != null) trailing!,
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, size: AppDimensions.iconSizeSM),
              color: AppColors.textSecondary,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
