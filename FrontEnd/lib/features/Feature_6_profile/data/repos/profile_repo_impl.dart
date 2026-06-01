import '../data_sources/profile_local_data_source.dart';
import 'profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  ProfileRepoImpl(this._local);

  final ProfileLocalDataSource _local;

  @override
  String get displayName => _local.displayName;

  @override
  String get countryCode => _local.countryCode;

  @override
  String get currencyCode => _local.currencyCode;

  @override
  String get gender => _local.gender;

  @override
  String get languageCode => _local.languageCode;

  @override
  Future<void> savePreferences({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
    required String languageCode,
  }) =>
      _local.save(
        displayName: displayName,
        countryCode: countryCode,
        currencyCode: currencyCode,
        gender: gender,
        languageCode: languageCode,
      );

  @override
  Future<void> logout() => _local.clearSession();
}
