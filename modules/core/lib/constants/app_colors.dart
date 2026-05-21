import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const mainColor = Color(0xFF125A4B);
  static const activeSwitchColor = Color(0xFF2F7D3B);
  static const inactiveSwitchColor = Color(0xFFB6BBC0);
  static const goldGradientColor = Color(0xFFFBEAC4);
  static const goldGradientColor2 = Color(0xFFC2A463);

  static const goldBorderColor = Color(0xFFC2A463);

  static const goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBEAC4), Color(0xFFC2A463)],
  );

  static final goldBorder = Border.all(
    color: goldBorderColor,
  );
}
