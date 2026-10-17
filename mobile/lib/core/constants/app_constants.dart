class AppConstants {
  // Matches the Dhahabu/Rafiki development PC's LAN address for physical phones.
  // Override when the PC's address changes, or use 10.0.2.2 on an Android emulator.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.1.233:8000/api');
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String languageKey = 'language';
}
