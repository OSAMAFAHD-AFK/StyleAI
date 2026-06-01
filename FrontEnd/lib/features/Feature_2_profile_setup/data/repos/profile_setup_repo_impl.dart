import '../data_sources/local_profile_data_source.dart';
import 'profile_setup_repo.dart';

class ProfileSetupRepoImpl implements ProfileSetupRepo {
  ProfileSetupRepoImpl(this._local);

  final LocalProfileDataSource _local;

  @override
  Future<void> completeSetup({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
  }) {
    return _local.saveProfile(
      displayName: displayName,
      countryCode: countryCode,
      currencyCode: currencyCode,
      gender: gender,
    );
  }
}
