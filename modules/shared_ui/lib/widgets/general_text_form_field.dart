import 'package:core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GeneralTextFormField extends StatelessWidget {
  const GeneralTextFormField({
    super.key,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.obscureText = false,
    this.enabled = true,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.borderSide,
  });

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool obscureText;
  final bool enabled;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xff8a9aa5)),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: const Color(0xff8a9aa5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xffe7eaec),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: borderSide ?? BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.mainColor, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
