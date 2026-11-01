import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto reutilizables que no forman parte del TextTheme.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.brandDark,
  );
}
