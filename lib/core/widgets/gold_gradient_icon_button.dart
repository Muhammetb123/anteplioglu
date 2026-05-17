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
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? iconSize;

  static const Color _borderColor = Color(0xffC2A463);
  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBEAC4), Color(0xFFC2A463)],
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: icon == Icons.arrow_back_ios_new
          ? BorderRadius.circular(100)
          : BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: icon == Icons.arrow_back_ios_new
              ? null
              : BorderRadius.circular(borderRadius),
          shape: icon == Icons.arrow_back_ios_new
              ? BoxShape.circle
              : BoxShape.rectangle,
          border: Border.all(color: _borderColor, width: 1.5),
          gradient: _gradient,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
