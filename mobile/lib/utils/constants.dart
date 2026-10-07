class AppConstants {
  // Override per device/environment with:
  // flutter run --dart-define=API_BASE_URL=http://<computer-ip>:8000/api
  // Android emulators can use http://10.0.2.2:8000/api instead.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.1.182:8000/api,http://127.0.0.1:8000/api');
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String languageKey = 'language';
}
