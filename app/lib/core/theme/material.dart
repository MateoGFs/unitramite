import 'package:flutter/material.dart';

/// Paleta de UniTrámite. Para cambiar la identidad visual, basta con editar este archivo.
class AppColors {
  AppColors._();

  // Tinta: color principal, como la tinta de un sello oficial.
  static const Color ink = Color(0xFF1C2F6B);
  static const Color inkDark = Color(0xFF111E4A);
  static const Color inkTint = Color(0xFFDDE4FA);

  // Sello: acento. Se usa solo para lo que debe llamar la atención.
  static const Color stamp = Color(0xFFF0A81C);
  static const Color stampTint = Color(0xFFFFEFC7);
  static const Color stampInk = Color(0xFF4A3300);

  // Superficies y texto.
  static const Color paper = Color(0xFFFFFFFF);
  static const Color sky = Color(0xFFF2F4FA);
  static const Color text = Color(0xFF1A1F2E);
  static const Color muted = Color(0xFF5B6478);
  static const Color line = Color(0xFFDDE2EE);

  // Estados.
  static const Color ok = Color(0xFF2E7D5B);
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerTint = Color(0xFFFBE4E1);
  static const Color dangerInk = Color(0xFF5A110C);
}