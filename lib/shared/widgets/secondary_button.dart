import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
      ),
    );
  }
}
