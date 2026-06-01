abstract class ProfileSetupRepo {
  Future<void> completeSetup({
    required String displayName,
    required String countryCode,
    required String currencyCode,
    required String gender,
  });
}
