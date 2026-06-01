import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/utils/api_service.dart';

class LocalProfileDataSource {
  LocalProfileDataSource(this._prefs, this._api);

  final UserPreferencesService _prefs;
  final ApiService _api;

  Future<void> saveProfile({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
  }) async {
    await _prefs.saveProfile(
      displayName: displayName,
      countryCode: countryCode,
      currencyCode: currencyCode,
      gender: gender,
    );
    _api.setCountryCode(countryCode);
  }
}
