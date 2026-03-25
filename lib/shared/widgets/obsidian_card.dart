import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ObsidianCard extends StatelessWidget {
  const ObsidianCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.radius = 28,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double radius;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
          if (glow)
            BoxShadow(
              color: AppColors.primary.withOpacity(.10),
              blurRadius: 24,
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );
  }
}
