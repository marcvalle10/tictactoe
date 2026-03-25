import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? helperText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        suffixIcon: suffixIcon,
        helperText: helperText,
        helperStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.xColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
