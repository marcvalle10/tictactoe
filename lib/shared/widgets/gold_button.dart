import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 60,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? AppColors.surfaceHigher : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(.18),
                    blurRadius: 26,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: disabled ? AppColors.textSecondary : AppColors.surfaceLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          icon: icon != null ? Icon(icon, size: 22) : const SizedBox.shrink(),
          label: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
