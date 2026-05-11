import 'package:flutter/material.dart';

class AuthTheme {
  static const Color primaryGreen = Color(0xFF0B5B4B);
  static const Color fieldFill = Color(0xFFF3F5F7);
  static const Color fieldIcon = Color(0xFF8A9AA5);

  static InputDecoration inputDecoration({
    required IconData icon,
    Widget? suffixIcon,
    String? hint,
    Color? suffixIconColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: fieldIcon),
      filled: true,
      fillColor: fieldFill,
      prefixIcon: Icon(icon, color: fieldIcon),
      suffixIcon: suffixIcon,
      suffixIconColor: suffixIconColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
