import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMinerGlassTheme =
        theme.scaffoldBackgroundColor == Colors.transparent;
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(isMinerGlassTheme ? 18 : 8);
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isMinerGlassTheme
            ? theme.cardColor
            : isDark
                ? AppColors.surfaceDark
                : Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: isMinerGlassTheme
              ? (isDark
                  ? Colors.white24
                  : AppColors.navy.withValues(alpha: .14))
              : isDark
                  ? AppColors.border
                  : Colors.black12,
        ),
      ),
      child: child,
    );

    if (!isMinerGlassTheme) return card;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: card,
      ),
    );
  }
}
