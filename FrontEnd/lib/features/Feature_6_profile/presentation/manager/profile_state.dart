part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.displayName = 'Julian Vane',
    this.countryCode = 'SA',
    this.currencyCode = 'SAR',
    this.gender = 'female',
    this.languageCode = 'en',
    this.isEditing = false,
    this.isSaving = false,
    this.saved = false,
  });

  final String displayName;
  final String countryCode;
  final String currencyCode;
  final String gender;
  final String languageCode;
  final bool isEditing;
  final bool isSaving;
  final bool saved;

  ProfileState copyWith({
    String? displayName,
    String? countryCode,
    String? currencyCode,
    String? gender,
    String? languageCode,
    bool? isEditing,
    bool? isSaving,
    bool? saved,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      gender: gender ?? this.gender,
      languageCode: languageCode ?? this.languageCode,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        countryCode,
        currencyCode,
        gender,
        languageCode,
        isEditing,
        isSaving,
        saved,
      ];
}
