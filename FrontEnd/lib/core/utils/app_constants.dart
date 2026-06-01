/// Runtime configuration — override via `--dart-define=API_BASE_URL=...`.
abstract final class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String signalRHubPath = '/hubs/search-offers';
  static const String deviceTokenKey = 'device_token';
  static const String profileCompletedKey = 'profile_completed';
  static const String userDisplayNameKey = 'user_display_name';
  static const String preferredCountryKey = 'preferred_country';
  static const String preferredCurrencyKey = 'preferred_currency';
  static const String genderKey = 'gender';
  static const String languageKey = 'language_code';
  static const String thriftSavingsKey = 'thrift_total_savings';
  static const String thriftCurrencyKey = 'thrift_currency';
}
