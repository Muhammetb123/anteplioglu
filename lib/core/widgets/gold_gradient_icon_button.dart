import 'package:antepli/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Altın gradient çerçeveli küçük ikon butonu (ör. AppBar çekmece tetikleyicisi).
class GoldGradientIconButton extends StatelessWidget {
  const GoldGradientIconButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.more_vert,
    this.iconColor = Colors.black,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.all(5),
    this.iconSize,
    this.isCircle = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? iconSize;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: isCircle
          ? BorderRadius.circular(100)
          : BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(borderRadius),
          shape: isCircle
              ? BoxShape.circle
              : BoxShape.rectangle,
          border: AppColors.goldBorder,
          gradient: AppColors.goldGradient,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
