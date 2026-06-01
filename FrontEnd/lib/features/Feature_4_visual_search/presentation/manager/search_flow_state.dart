part of 'search_flow_cubit.dart';

enum SearchFlowStatus {
  idle,
  uploading,
  readyToSearch,
  processing,
  loadingResults,
  resultsReady,
  failure,
}

class SearchFlowState extends Equatable {
  const SearchFlowState({
    this.status = SearchFlowStatus.idle,
    this.localImagePath,
    this.captureSource,
    this.searchResult,
    this.requestId,
    this.progress = 0,
    this.streamedOffers = const [],
    this.rankedResult,
    this.errorMessage,
  });

  final SearchFlowStatus status;
  final String? localImagePath;
  final CaptureSource? captureSource;
  final ImageSearchResult? searchResult;
  final String? requestId;
  final double progress;
  final List<AffiliateProductOffer> streamedOffers;
  final RankedOffersResult? rankedResult;
  final String? errorMessage;

  bool get hasActiveSession => localImagePath != null;

  bool get canSearch =>
      localImagePath != null && status != SearchFlowStatus.uploading;

  bool get hasCompletedResults =>
      requestId != null &&
      rankedResult != null &&
      status == SearchFlowStatus.resultsReady;

  int get progressPercent => (progress * 100).clamp(0, 100).round();

  SearchFlowState copyWith({
    SearchFlowStatus? status,
    String? localImagePath,
    CaptureSource? captureSource,
    ImageSearchResult? searchResult,
    String? requestId,
    double? progress,
    List<AffiliateProductOffer>? streamedOffers,
    RankedOffersResult? rankedResult,
    String? errorMessage,
    bool clearImage = false,
    bool clearSource = false,
    bool clearSearchResult = false,
    bool clearRequestId = false,
  }) {
    return SearchFlowState(
      status: status ?? this.status,
      localImagePath: clearImage ? null : (localImagePath ?? this.localImagePath),
      captureSource: clearSource ? null : (captureSource ?? this.captureSource),
      searchResult:
          clearSearchResult ? null : (searchResult ?? this.searchResult),
      requestId: clearRequestId ? null : (requestId ?? this.requestId),
      progress: progress ?? this.progress,
      streamedOffers: streamedOffers ?? this.streamedOffers,
      rankedResult: rankedResult ?? this.rankedResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        localImagePath,
        captureSource,
        requestId,
        progress,
        streamedOffers.length,
        rankedResult,
      ];
}
