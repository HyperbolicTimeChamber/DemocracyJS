import 'package:flutter/material.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';
import 'status_badge.dart';

class PollCard extends StatelessWidget {
  const PollCard({
    super.key,
    required this.question,
    required this.status,
    required this.optionCount,
    required this.onTap,
  });

  final String question;
  final PollStatus status;
  final int optionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(question, style: AppTextStyles.h3),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                '$optionCount options',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
