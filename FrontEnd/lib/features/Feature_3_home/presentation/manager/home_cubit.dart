import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/thrift_counter_summary.dart';
import '../../../Feature_5_collections/data/models/search_history_item_model.dart';
import '../../data/repos/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo)
      : super(
          HomeState(
            displayName: _repo.getDisplayName(),
            gender: _repo.getGender(),
            recentSearchResults: _repo.getRecentSearchResults(),
            thrift: _repo.getCachedThriftSummary(),
          ),
        );

  final HomeRepo _repo;

  Future<void> load() async {
    if (isClosed) return;

    emit(
      state.copyWith(
        displayName: _repo.getDisplayName(),
        gender: _repo.getGender(),
        recentSearchResults: _repo.getRecentSearchResults(),
        thrift: _repo.getCachedThriftSummary(),
      ),
    );

    try {
      final thrift = await _repo.getThriftSummary();
      if (isClosed) return;
      emit(state.copyWith(thrift: thrift, isRefreshingThrift: false));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isRefreshingThrift: false, error: e.toString()));
    }
  }
}
