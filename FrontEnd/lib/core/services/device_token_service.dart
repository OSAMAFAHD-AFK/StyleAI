import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_constants.dart';

/// Persists anonymous device identity used by [X-Device-Token] header.
class DeviceTokenService {
  DeviceTokenService(this._prefs);

  final SharedPreferences _prefs;

  Future<String> getOrCreateToken() async {
    final existing = _prefs.getString(AppConstants.deviceTokenKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final token = const Uuid().v4();
    await _prefs.setString(AppConstants.deviceTokenKey, token);
    return token;
  }

  String? get token => _prefs.getString(AppConstants.deviceTokenKey);
}
