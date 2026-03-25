import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class UniSonBadge extends StatelessWidget {
  const UniSonBadge({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(size * .28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECE1C7),
          borderRadius: BorderRadius.circular(size * .18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * .18),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/logo_unison.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key, this.color = AppColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
      ),
    );
  }
}

class SoftStatusDot extends StatelessWidget {
  const SoftStatusDot({super.key, this.color = AppColors.primary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.45),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
