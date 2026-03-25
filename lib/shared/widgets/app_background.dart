import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.safeArea = true,
    this.padding,
  });

  final Widget child;
  final bool safeArea;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, AppColors.backgroundSoft],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -120,
          top: 180,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.xColor.withOpacity(.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -80,
          bottom: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
        if (padding != null)
          Positioned.fill(
            child: Padding(
              padding: padding!,
              child: child,
            ),
          )
        else
          Positioned.fill(child: child),
      ],
    );

    return safeArea ? SafeArea(child: content) : content;
  }
}
