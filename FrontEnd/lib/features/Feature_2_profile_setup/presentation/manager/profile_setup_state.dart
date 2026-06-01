part of 'profile_setup_cubit.dart';

class ProfileSetupState extends Equatable {
  const ProfileSetupState({
    this.displayName = '',
    this.gender = 'female',
    this.countryCode = 'SA',
    this.currencyCode = 'SAR',
    this.isSaving = false,
    this.isComplete = false,
    this.error,
  });

  final String displayName;
  final String gender;
  final String countryCode;
  final String currencyCode;
  final bool isSaving;
  final bool isComplete;
  final String? error;

  bool get canSubmit => displayName.trim().isNotEmpty;

  ProfileSetupState copyWith({
    String? displayName,
    String? gender,
    String? countryCode,
    String? currencyCode,
    bool? isSaving,
    bool? isComplete,
    String? error,
  }) {
    return ProfileSetupState(
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      isSaving: isSaving ?? this.isSaving,
      isComplete: isComplete ?? this.isComplete,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        gender,
        countryCode,
        currencyCode,
        isSaving,
        isComplete,
        error,
      ];
}
