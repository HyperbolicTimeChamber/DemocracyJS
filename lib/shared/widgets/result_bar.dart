import 'package:flutter/material.dart';
import 'package:democracy_js/core/theme/app_colors.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';

class ResultBar extends StatelessWidget {
  const ResultBar({
    super.key,
    required this.text,
    required this.voteCount,
    required this.totalVotes,
  });

  final String text;
  final int voteCount;
  final int totalVotes;

  double get _percentage => totalVotes > 0 ? voteCount / totalVotes : 0;
  String get _percentLabel => '${(_percentage * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(text, style: AppTextStyles.body)),
              Text('$voteCount', style: AppTextStyles.body),
              const SizedBox(width: AppDimensions.paddingSM),
              SizedBox(
                width: 40,
                child: Text(
                  _percentLabel,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: SizedBox(
              height: AppDimensions.resultBarHeight,
              child: Stack(
                children: [
                  Container(color: AppColors.surface),
                  FractionallySizedBox(
                    widthFactor: _percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryVariant],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
