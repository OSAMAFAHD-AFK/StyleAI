import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState());

  final ProfileRepo _repo;

  void load() {
    emit(ProfileState(
      displayName: _repo.displayName,
      countryCode: _repo.countryCode,
      currencyCode: _repo.currencyCode,
      gender: _repo.gender,
      languageCode: _repo.languageCode,
    ));
  }

  void startEditing() => emit(state.copyWith(isEditing: true, saved: false));

  void cancelEditing() {
    emit(ProfileState(
      displayName: _repo.displayName,
      countryCode: _repo.countryCode,
      currencyCode: _repo.currencyCode,
      gender: _repo.gender,
      languageCode: _repo.languageCode,
    ));
  }

  void updateDisplayName(String name) => emit(state.copyWith(displayName: name));

  void updateGender(String gender) => emit(state.copyWith(gender: gender));

  void updateCountry(String code) => emit(state.copyWith(countryCode: code));

  void updateCurrency(String code) => emit(state.copyWith(currencyCode: code));

  void updateLanguage(String code) => emit(state.copyWith(languageCode: code));

  Future<void> saveChanges() async {
    emit(state.copyWith(isSaving: true));
    await _repo.savePreferences(
      displayName: state.displayName,
      countryCode: state.countryCode,
      currencyCode: state.currencyCode,
      gender: state.gender,
      languageCode: state.languageCode,
    );
    emit(state.copyWith(isSaving: false, saved: true, isEditing: false));
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const ProfileState());
  }
}
