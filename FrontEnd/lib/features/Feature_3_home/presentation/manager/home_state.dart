part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.isRefreshingThrift = false,
    this.displayName = 'Guest',
    this.gender = 'female',
    this.thrift,
    this.recentSearchResults = const [],
    this.error,
  });

  final bool isRefreshingThrift;
  final String displayName;
  final String gender;
  final ThriftCounterSummary? thrift;
  final List<SearchHistoryItemModel> recentSearchResults;
  final String? error;

  HomeState copyWith({
    bool? isRefreshingThrift,
    String? displayName,
    String? gender,
    ThriftCounterSummary? thrift,
    List<SearchHistoryItemModel>? recentSearchResults,
    String? error,
  }) {
    return HomeState(
      isRefreshingThrift: isRefreshingThrift ?? this.isRefreshingThrift,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      thrift: thrift ?? this.thrift,
      recentSearchResults: recentSearchResults ?? this.recentSearchResults,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isRefreshingThrift,
        displayName,
        gender,
        thrift,
        recentSearchResults,
        error,
      ];
}
