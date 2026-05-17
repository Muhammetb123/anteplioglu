import 'package:antepli/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum GeneralButtonVariant { gold, green }

class GeneralButton extends StatelessWidget {
  const GeneralButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.variant = GeneralButtonVariant.gold,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double? width;
  final GeneralButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && onPressed != null;
    final isGold = variant == GeneralButtonVariant.gold;

    return SizedBox(
      height: height,
      width: width,
      child: isGold
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: AppColors.goldBorder,
                gradient: AppColors.goldGradient,
              ),
              child: _button(
                isEnabled: isEnabled,
                radius: 8,
                textColor: Colors.black,
                textSize: 16,
                textWeight: FontWeight.w500,
                loadingColor: Colors.black,
                transparentBackground: true,
              ),
            )
          : _button(
              isEnabled: isEnabled,
              radius: 14,
              textColor: Colors.white,
              textSize: 18,
              textWeight: FontWeight.w700,
              loadingColor: Colors.white,
              backgroundColor: AppColors.mainColor,
            ),
    );
  }

  Widget _button({
    required bool isEnabled,
    required double radius,
    required Color textColor,
    required double textSize,
    required FontWeight textWeight,
    required Color loadingColor,
    Color? backgroundColor,
    bool transparentBackground = false,
  }) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: transparentBackground
            ? Colors.transparent
            : backgroundColor,
        disabledBackgroundColor: transparentBackground
            ? Colors.transparent
            : backgroundColor,
        foregroundColor: textColor,
        disabledForegroundColor: textColor.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: loadingColor,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
                fontWeight: textWeight,
              ),
            ),
    );
  }
}
