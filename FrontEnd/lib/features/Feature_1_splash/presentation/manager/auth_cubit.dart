import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repos/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepo _repo;

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      await _repo.signInWithGoogle();
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
