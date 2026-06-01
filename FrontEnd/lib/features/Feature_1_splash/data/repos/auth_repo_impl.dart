import '../data_sources/local_auth_data_source.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._local);

  final LocalAuthDataSource _local;

  @override
  Future<String> signInWithGoogle() async {
    // Placeholder until Google Sign-In SDK is wired.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _local.ensureDeviceToken();
  }
}
