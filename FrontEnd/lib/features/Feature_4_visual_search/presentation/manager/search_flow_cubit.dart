import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/affiliate_product_offer.dart';
import '../../../../core/models/garment_tags.dart';
import '../../../../core/models/image_search_result.dart';
import '../../../../core/models/ranked_offers_result.dart';
import '../../data/data_sources/search_mock_data_source.dart';
import '../../data/models/capture_source.dart';
import '../../data/repos/visual_search_repo.dart';

part 'search_flow_state.dart';

class SearchFlowCubit extends Cubit<SearchFlowState> {
  SearchFlowCubit(this._repo) : super(const SearchFlowState());

  final VisualSearchRepo _repo;

  void applyRouteExtra(Object? extra) {
    if (extra is! Map) return;

    final imagePath = extra['imagePath'];
    if (imagePath is! String || imagePath.isEmpty) return;

    final sourceName = extra['source'];
    final source = sourceName == CaptureSource.camera.name
        ? CaptureSource.camera
        : CaptureSource.gallery;

    startSession(imagePath: imagePath, source: source);
  }

  Future<void> startSession({
    required String imagePath,
    required CaptureSource source,
  }) async {
    emit(SearchFlowState(
      localImagePath: imagePath,
      captureSource: source,
      status: SearchFlowStatus.uploading,
    ));
    await uploadAndAnalyze();
  }

  void clearSession() {
    emit(const SearchFlowState());
  }

  Future<void> uploadAndAnalyze() async {
    final path = state.localImagePath;
    if (path == null) return;

    emit(state.copyWith(status: SearchFlowStatus.uploading));

    try {
      final bytes = await File(path).readAsBytes();
      final result = await _repo.uploadImage(
        bytes: Uint8List.fromList(bytes),
        fileName: 'capture.jpg',
      );
      emit(state.copyWith(
        status: SearchFlowStatus.readyToSearch,
        searchResult: result,
        requestId: result.requestId,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SearchFlowStatus.readyToSearch,
        requestId: SearchMockDataSource.demoRequestId,
        searchResult: _demoSearchResult(),
      ));
    }
  }

  /// Returns an existing [requestId] or assigns a demo id for offline search.
  String ensureRequestId() {
    final existing = state.requestId;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    emit(state.copyWith(
      requestId: SearchMockDataSource.demoRequestId,
      searchResult: _demoSearchResult(),
    ));
    return SearchMockDataSource.demoRequestId;
  }

  ImageSearchResult _demoSearchResult() => ImageSearchResult(
        requestId: SearchMockDataSource.demoRequestId,
        tags: const GarmentTags(
          category: 'Dress',
          color: 'Black',
          style: 'Formal',
        ),
        tagsStatus: 'available',
      );

  Future<void> startOffersPipeline(String requestId) async {
    if (state.status == SearchFlowStatus.processing &&
        state.requestId == requestId) {
      return;
    }

    if (state.status == SearchFlowStatus.resultsReady &&
        state.requestId == requestId &&
        state.rankedResult != null) {
      return;
    }

    emit(state.copyWith(
      status: SearchFlowStatus.processing,
      requestId: requestId,
      progress: 0,
    ));

    if (SearchMockDataSource.usePreviewData ||
        SearchMockDataSource.isDemoRequestId(requestId)) {
      await _runMockPipeline(requestId);
      return;
    }

    try {
      await _repo.startOffersSearch(requestId);
      await _repo.connectStream(
        requestId: requestId,
        onProgress: (p) {
          if (!isClosed) emit(state.copyWith(progress: p));
        },
      );

      _repo.watchOffers().listen((offer) {
        if (isClosed) return;
        final updated = List<AffiliateProductOffer>.from(state.streamedOffers)
          ..add(offer);
        emit(state.copyWith(streamedOffers: updated));
      });

      _repo.watchSearchCompleted().listen((_) async {
        await _loadResults(requestId);
      });
    } catch (_) {
      await _runMockPipeline(requestId);
    }
  }

  Future<void> _runMockPipeline(String requestId) async {
    for (final step in SearchMockDataSource.processingProgressSteps) {
      await Future<void>.delayed(SearchMockDataSource.processingStepDelay);
      if (isClosed) return;
      emit(state.copyWith(
        status: SearchFlowStatus.processing,
        requestId: requestId,
        progress: step,
      ));
    }

    if (isClosed) return;
    emit(state.copyWith(
      status: SearchFlowStatus.resultsReady,
      requestId: requestId,
      rankedResult: SearchMockDataSource.buildResults(requestId),
      progress: 1,
    ));
  }

  Future<void> loadResults(String requestId) async {
    emit(state.copyWith(status: SearchFlowStatus.loadingResults, requestId: requestId));

    if (SearchMockDataSource.usePreviewData ||
        SearchMockDataSource.isDemoRequestId(requestId)) {
      emit(state.copyWith(
        status: SearchFlowStatus.resultsReady,
        rankedResult: SearchMockDataSource.buildResults(requestId),
        progress: 1,
      ));
      return;
    }

    await _loadResults(requestId);
  }

  bool _isEmptyResult(RankedOffersResult? ranked) =>
      ranked == null ||
      (ranked.originals.isEmpty && ranked.dupes.isEmpty);

  RankedOffersResult _resultsOrPreview(String requestId, RankedOffersResult? ranked) {
    if (_isEmptyResult(ranked)) {
      return SearchMockDataSource.buildResults(requestId);
    }
    return ranked!;
  }

  Future<void> _loadResults(String requestId) async {
    try {
      final ranked = await _repo.getOffers(requestId);
      emit(state.copyWith(
        status: SearchFlowStatus.resultsReady,
        rankedResult: _resultsOrPreview(requestId, ranked),
        progress: 1,
      ));
      await _repo.disconnectStream(requestId);
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: SearchFlowStatus.resultsReady,
        rankedResult: SearchMockDataSource.buildResults(requestId),
        progress: 1,
      ));
    }
  }

  Future<String?> prepareBuyLink(AffiliateProductOffer offer) async {
    final requestId = state.requestId;
    if (requestId == null) return null;
    return _repo.prepareBuyLink(requestId: requestId, offerId: offer.offerId);
  }

  @override
  Future<void> close() async {
    final id = state.requestId;
    if (id != null) await _repo.disconnectStream(id);
    return super.close();
  }
}
