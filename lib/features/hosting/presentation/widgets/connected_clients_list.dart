import 'package:flutter/material.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';

class ConnectedClientsList extends StatelessWidget {
  const ConnectedClientsList({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Text('$count clients connected', style: AppTextStyles.body),
    );
  }
}
