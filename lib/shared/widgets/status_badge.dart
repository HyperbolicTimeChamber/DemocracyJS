import 'package:flutter/material.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/theme/app_colors.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final PollStatus status;

  Color get _color {
    switch (status) {
      case PollStatus.draft:
        return AppColors.textSecondary;
      case PollStatus.hosting:
        return AppColors.success;
      case PollStatus.paused:
        return AppColors.warning;
      case PollStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: _color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(color: _color),
      ),
    );
  }
}
