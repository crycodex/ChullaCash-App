import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
