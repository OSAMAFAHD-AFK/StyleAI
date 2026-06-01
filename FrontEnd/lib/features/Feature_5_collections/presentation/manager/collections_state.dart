part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({
    this.savedOffers = const [],
    this.searchHistory = const [],
    this.selectedTabIndex = CollectionsNavigation.savedTab,
  });

  final List<AffiliateProductOffer> savedOffers;
  final List<SearchHistoryItemModel> searchHistory;
  final int selectedTabIndex;

  CollectionsState copyWith({
    List<AffiliateProductOffer>? savedOffers,
    List<SearchHistoryItemModel>? searchHistory,
    int? selectedTabIndex,
  }) {
    return CollectionsState(
      savedOffers: savedOffers ?? this.savedOffers,
      searchHistory: searchHistory ?? this.searchHistory,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [savedOffers, searchHistory, selectedTabIndex];
}
