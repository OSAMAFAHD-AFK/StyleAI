import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/utils/api_service.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource(this._prefs, this._api);

  final UserPreferencesService _prefs;
  final ApiService _api;

  String get displayName => _prefs.displayName;
  String get countryCode => _prefs.preferredCountry;
  String get currencyCode => _prefs.preferredCurrency;
  String get gender => _prefs.gender;
  String get languageCode => _prefs.languageCode;

  Future<void> save({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
    required String languageCode,
  }) async {
    await _prefs.saveProfile(
      displayName: displayName,
      countryCode: countryCode,
      currencyCode: currencyCode,
      gender: gender,
      languageCode: languageCode,
    );
    _api.setCountryCode(countryCode);
  }

  Future<void> clearSession() => _prefs.clearSession();
}
