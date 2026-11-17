import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema visual de UniTrámite: Bricolage Grotesque en títulos y Public Sans en texto.
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(TextTheme base) {
    // Texto corrido: Public Sans.
    TextStyle body(TextStyle? style) =>
        GoogleFonts.publicSans(textStyle: style, color: AppColors.text);

    // Títulos: Bricolage Grotesque.
    TextStyle title(TextStyle? style, FontWeight weight, double spacing) {
      return GoogleFonts.bricolageGrotesque(
        textStyle: style,
        color: AppColors.text,
        fontWeight: weight,
        letterSpacing: spacing,
      );
    }

    return base.copyWith(
      displayLarge: body(base.displayLarge),
      displayMedium: body(base.displayMedium),
      displaySmall: body(base.displaySmall),
      headlineLarge: title(base.headlineLarge, FontWeight.w700, -0.6),
      headlineMedium: title(base.headlineMedium, FontWeight.w700, -0.5),
      headlineSmall: title(base.headlineSmall, FontWeight.w700, -0.3),
      titleLarge: title(base.titleLarge, FontWeight.w700, -0.2),
      titleMedium: title(base.titleMedium, FontWeight.w600, 0),
      titleSmall: title(base.titleSmall, FontWeight.w600, 0),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium),
      bodySmall: body(base.bodySmall),
      labelLarge: body(base.labelLarge),
      labelMedium: body(base.labelMedium),
      labelSmall: body(base.labelSmall),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.ink).copyWith(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      primaryContainer: AppColors.inkTint,
      onPrimaryContainer: AppColors.inkDark,
      secondary: AppColors.ink,
      onSecondary: Colors.white,
      tertiary: AppColors.stamp,
      onTertiary: AppColors.inkDark,
      tertiaryContainer: AppColors.stampTint,
      onTertiaryContainer: AppColors.stampInk,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerTint,
      onErrorContainer: AppColors.dangerInk,
      surface: AppColors.paper,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      outlineVariant: AppColors.line,
    );

    final text = _textTheme(ThemeData(brightness: Brightness.light).textTheme);

    OutlineInputBorder inputBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.sky,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sky,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
        titleTextStyle: text.titleLarge?.copyWith(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.muted),
        border: inputBorder(AppColors.line, 1),
        enabledBorder: inputBorder(AppColors.line, 1),
        focusedBorder: inputBorder(AppColors.ink, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.ink),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paper,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.inkTint,
        linearMinHeight: 6,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: AppColors.muted, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.ink : null,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inkDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}