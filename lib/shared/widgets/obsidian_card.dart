import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ObsidianCard extends StatelessWidget {
  const ObsidianCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF20273B)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
