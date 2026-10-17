import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.iconMuted,
    required this.goldTint,
    required this.accent,
    required this.appBar,
    required this.onAppBar,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color iconMuted;
  final Color goldTint;
  final Color accent;
  final Color appBar;
  final Color onAppBar;

  static const light = AppPalette(
    background: AppColors.white,
    surface: AppColors.white,
    surfaceAlt: AppColors.background,
    textPrimary: AppColors.navy,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    iconMuted: AppColors.textSecondary,
    goldTint: Color(0x26C9A227), // ~15% gold
    accent: AppColors.navy,
    appBar: AppColors.navy,
    onAppBar: AppColors.white,
  );

  static final dark = AppPalette(
    background: AppColors.navy,
    surface: AppColors.navyLight,
    surfaceAlt: Color(0xFF0F2A4D),
    textPrimary: AppColors.white,
    textSecondary: Colors.white70,
    border: Color(0x1FFFFFFF), // white at ~12%
    iconMuted: Colors.white70,
    goldTint: Color(0x33C9A227), // ~20% gold
    accent: AppColors.goldLight,
    appBar: AppColors.navy,
    onAppBar: AppColors.white,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? iconMuted,
    Color? goldTint,
    Color? accent,
    Color? appBar,
    Color? onAppBar,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      iconMuted: iconMuted ?? this.iconMuted,
      goldTint: goldTint ?? this.goldTint,
      accent: accent ?? this.accent,
      appBar: appBar ?? this.appBar,
      onAppBar: onAppBar ?? this.onAppBar,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      goldTint: Color.lerp(goldTint, other.goldTint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      appBar: Color.lerp(appBar, other.appBar, t)!,
      onAppBar: Color.lerp(onAppBar, other.onAppBar, t)!,
    );
  }
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
