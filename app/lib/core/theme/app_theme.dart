import 'package:flutter/material.dart';

/// Tema visual de UniTrámite.
/// El color base es provisional y se puede cambiar en [seed].
class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF1565C0);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}