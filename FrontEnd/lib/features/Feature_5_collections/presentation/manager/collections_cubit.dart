import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/affiliate_product_offer.dart';
import '../../data/models/search_history_item_model.dart';
import '../../data/repos/collections_repo.dart';
import '../utils/collections_navigation.dart';

part 'collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit(this._repo, {int initialTabIndex = CollectionsNavigation.savedTab})
      : super(CollectionsState(
          selectedTabIndex: _clampTab(initialTabIndex),
        ));

  final CollectionsRepo _repo;

  static int _clampTab(int index) => index.clamp(0, 1);

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: _clampTab(index)));
  }

  void load() {
    emit(state.copyWith(
      savedOffers: _repo.getSavedOffers(),
      searchHistory: _repo.getSearchHistory(),
    ));
  }

  void removeSavedOffer(String offerId) {
    _repo.removeSavedOffer(offerId);
    emit(state.copyWith(savedOffers: _repo.getSavedOffers()));
  }
}
