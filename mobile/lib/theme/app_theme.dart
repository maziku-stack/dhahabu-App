import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData dhahabuTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy,
      secondary: AppColors.gold,
      surface: AppColors.white,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.navy,
      onSurface: AppColors.navy,
      onSurfaceVariant: AppColors.textSecondary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.urbanist(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
      titleLarge: GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      titleMedium: GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      bodyLarge: GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.navy,
      ),
      bodyMedium: GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.navy,
      ),
      bodySmall: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      labelMedium: GoogleFonts.publicSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
      ),
      labelSmall: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.publicSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.publicSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy,
        textStyle: GoogleFonts.publicSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}

ThemeData dhahabuDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.navyLight,
      surface: AppColors.navyLight,
      error: AppColors.error,
      onPrimary: AppColors.navy,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.textSecondary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navyLight,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.urbanist(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      titleLarge: GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleMedium: GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      bodyLarge: GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      bodyMedium: GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      bodySmall: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      labelMedium: GoogleFonts.publicSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      labelSmall: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.publicSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.publicSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.navyLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}

// Compatibility wrappers
ThemeData buildDhahabuTheme() => dhahabuDarkTheme();
ThemeData buildDhahabuLightTheme() => dhahabuTheme();
ThemeData buildGlassDashboardTheme(ThemeData base) => base;
