class AppConstants {
  AppConstants._();

  /// Nombre y lema del encabezado. Si se decide otro nombre de marca,
  /// se cambia solo aquí.
  static const String brandName = 'TRAMITAU';
  static const String brandTagline = 'Tu asistente guía para la Udenar';

  /// Dirección del backend. En Chrome es localhost. Para celular físico o
  /// emulador cambiará (lo veremos más adelante) usando --dart-define.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration requestTimeout = Duration(seconds: 60);
}