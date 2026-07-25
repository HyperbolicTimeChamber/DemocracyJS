import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:democracy_js/core/theme/app_colors.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';

class QRCodeWidget extends StatelessWidget {
  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = AppDimensions.qrCodeSize,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: AppColors.backgroundLight,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.backgroundDark,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.backgroundDark,
        ),
      ),
    );
  }
}
