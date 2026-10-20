class AppConstants {
  AppConstants._();

  /// Dirección del backend. En Chrome es localhost. Para celular físico o
  /// emulador cambiará (lo veremos más adelante) usando --dart-define.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration requestTimeout = Duration(seconds: 30);
}