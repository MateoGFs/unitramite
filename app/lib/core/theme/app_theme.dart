import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema visual de UniTrámite. Los colores viven en [AppColors].
class AppTheme {
  AppTheme._();

  static const Color seed = AppColors.primary;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: seed).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.warmWhite,
      onSurface: AppColors.brandDark,
      outlineVariant: AppColors.brandBorder,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.warmWhite,
      textTheme: GoogleFonts.robotoFlexTextTheme(base.textTheme).apply(
        bodyColor: AppColors.brandDark,
        displayColor: AppColors.brandDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brandDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.brandMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.brandMuted,
          ),
        ),
      ),
    );
  }
}
