import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repos/profile_setup_repo.dart';

part 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit(this._repo) : super(const ProfileSetupState());

  final ProfileSetupRepo _repo;

  void updateDisplayName(String name) {
    emit(state.copyWith(displayName: name));
  }

  void selectGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void selectCountry(String code) {
    emit(state.copyWith(countryCode: code));
  }

  void selectCurrency(String code) {
    emit(state.copyWith(currencyCode: code));
  }

  Future<void> completeSetup({String? displayName}) async {
    final name = (displayName ?? state.displayName).trim();
    if (name.isEmpty) return;

    emit(state.copyWith(displayName: name, isSaving: true, isComplete: false));
    try {
      await _repo.completeSetup(
        displayName: name,
        countryCode: state.countryCode,
        currencyCode: state.currencyCode,
        gender: state.gender,
      );
      emit(state.copyWith(isSaving: false, isComplete: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}
