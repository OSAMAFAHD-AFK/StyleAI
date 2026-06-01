import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/thrift_counter_summary.dart';
import '../utils/app_constants.dart';

class UserPreferencesService extends ChangeNotifier {
  UserPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  bool get isProfileCompleted =>
      _prefs.getBool(AppConstants.profileCompletedKey) ?? false;

  String get displayName =>
      _prefs.getString(AppConstants.userDisplayNameKey) ?? 'Guest';

  String get preferredCountry =>
      _prefs.getString(AppConstants.preferredCountryKey) ?? 'SA';

  String get preferredCurrency =>
      _prefs.getString(AppConstants.preferredCurrencyKey) ?? 'SAR';

  String get gender => _prefs.getString(AppConstants.genderKey) ?? 'female';

  String get languageCode =>
      _prefs.getString(AppConstants.languageKey) ?? 'en';

  ThriftCounterSummary? get cachedThriftSummary {
    final savings = _prefs.getDouble(AppConstants.thriftSavingsKey);
    if (savings == null) return null;

    return ThriftCounterSummary(
      userId: '',
      totalSavings: savings,
      currency: _prefs.getString(AppConstants.thriftCurrencyKey) ?? 'USD',
      totalClicks: 0,
      convertedClicks: 0,
    );
  }

  Future<void> saveThriftSummary(ThriftCounterSummary summary) async {
    await _prefs.setDouble(AppConstants.thriftSavingsKey, summary.totalSavings);
    await _prefs.setString(AppConstants.thriftCurrencyKey, summary.currency);
  }

  Future<void> saveProfile({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
    String? languageCode,
  }) async {
    await _prefs.setString(AppConstants.userDisplayNameKey, displayName);
    await _prefs.setString(AppConstants.preferredCountryKey, countryCode);
    await _prefs.setString(AppConstants.preferredCurrencyKey, currencyCode);
    await _prefs.setString(AppConstants.genderKey, gender);
    if (languageCode != null) {
      await _prefs.setString(AppConstants.languageKey, languageCode);
    }
    await _prefs.setBool(AppConstants.profileCompletedKey, true);
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.profileCompletedKey);
    await _prefs.remove(AppConstants.userDisplayNameKey);
    notifyListeners();
  }
}
