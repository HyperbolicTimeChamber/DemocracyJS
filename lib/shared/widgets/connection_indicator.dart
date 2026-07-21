import 'package:flutter/material.dart';
import 'package:local_poll/core/enums/connection_status.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key, required this.status});

  final ConnectionStatus status;

  Color get _color {
    switch (status) {
      case ConnectionStatus.connected:
        return AppColors.success;
      case ConnectionStatus.connecting:
        return AppColors.warning;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.statusDotSize,
          height: AppDimensions.statusDotSize,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        Text(status.label, style: AppTextStyles.caption),
      ],
    );
  }
}
