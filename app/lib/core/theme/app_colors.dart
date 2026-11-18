import 'package:flutter/material.dart';

/// Paleta de UniTrámite. Para cambiar la identidad visual, basta con editar este archivo.
class AppColors {
  AppColors._();

  // Verde institucional (los nombres "ink" se conservan para no tocar otros archivos).
  static const Color ink = Color(0xFF1B5E3F);
  static const Color inkDark = Color(0xFF0F3D29);
  static const Color inkTint = Color(0xFFD7EBDF);
  static const Color onInkMuted = Color(0xFFBFDCCB);

  // Sello: acento. Se usa solo para lo que debe llamar la atención.
  static const Color stamp = Color(0xFFF0A81C);
  static const Color stampTint = Color(0xFFFFEFC7);
  static const Color stampInk = Color(0xFF4A3300);

  // Superficies y texto, con un leve tono verdoso.
  static const Color paper = Color(0xFFFFFFFF);
  static const Color sky = Color(0xFFF3F6F2);
  static const Color text = Color(0xFF18211C);
  static const Color muted = Color(0xFF58665D);
  static const Color line = Color(0xFFDAE2DB);

  // Estados.
  static const Color ok = Color(0xFF2E7D5B);
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerTint = Color(0xFFFBE4E1);
  static const Color dangerInk = Color(0xFF5A110C);
}