import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildDhahabuTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.charcoal,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.navy,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textOnDark),
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.textOnDark),
      titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnDark),
      titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnDark),
      labelSmall: TextStyle(fontSize: 12, color: AppColors.textOnDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.navy,
      indicatorColor: AppColors.gold,
    ),
  );
}

ThemeData buildDhahabuLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.warmWhite,
    colorScheme: const ColorScheme.light(
      primary: AppColors.gold,
      secondary: AppColors.navy,
      surface: Colors.white,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.warmWhite,
      foregroundColor: AppColors.textOnLight,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

/// A high-contrast glass theme for authenticated dashboards and their pushed
/// screens. It preserves the selected palette and Dhahabu gold/navy identity.
ThemeData buildGlassDashboardTheme(ThemeData base) {
  final isDark = base.brightness == Brightness.dark;
  final foreground = isDark ? const Color(0xFFF7F8FA) : const Color(0xFF172334);
  final secondaryText =
      isDark ? const Color(0xFFD1D9E3) : const Color(0xFF455468);
  final glass = isDark ? const Color(0xD916293D) : const Color(0xEFFFFFFF);
  final line = isDark
      ? Colors.white.withValues(alpha: .16)
      : AppColors.navy.withValues(alpha: .12);
  final inputFill = isDark
      ? Colors.white.withValues(alpha: .09)
      : AppColors.navy.withValues(alpha: .045);
  final bodyStyle = TextStyle(color: foreground, fontFamily: 'Roboto');
  final secondaryStyle = TextStyle(color: secondaryText, fontFamily: 'Roboto');

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    cardColor: glass,
    colorScheme: base.colorScheme.copyWith(
      onSurface: foreground,
      onSurfaceVariant: secondaryText,
      surface: isDark ? const Color(0xFF15263A) : const Color(0xFFF8FAFC),
    ),
    textTheme: base.textTheme
        .apply(
          fontFamily: 'Roboto',
          bodyColor: foreground,
          displayColor: foreground,
        )
        .copyWith(
          bodySmall: bodyStyle.copyWith(fontSize: 14),
          bodyMedium: bodyStyle.copyWith(fontSize: 16),
          bodyLarge: bodyStyle.copyWith(fontSize: 18),
          titleSmall:
              bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          titleMedium:
              bodyStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
          titleLarge:
              bodyStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
          labelSmall: secondaryStyle.copyWith(fontSize: 13),
          labelMedium:
              bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          labelLarge:
              bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle:
          bodyStyle.copyWith(fontSize: 21, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: inputFill,
      labelStyle: secondaryStyle.copyWith(fontSize: 15),
      hintStyle: secondaryStyle.copyWith(fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.8),
      ),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor:
          isDark ? const Color(0xE6101F31) : const Color(0xEFFFFFFF),
      indicatorColor: AppColors.gold.withValues(alpha: .22),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
