abstract class ProfileRepo {
  String get displayName;
  String get countryCode;
  String get currencyCode;
  String get gender;
  String get languageCode;

  Future<void> savePreferences({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
    required String languageCode,
  });

  Future<void> logout();
}
