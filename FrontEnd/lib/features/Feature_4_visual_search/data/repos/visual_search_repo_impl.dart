import 'dart:typed_data';

import '../../../../core/models/affiliate_product_offer.dart';
import '../../../../core/models/image_search_result.dart';
import '../../../../core/models/offers_search_summary.dart';
import '../../../../core/models/ranked_offers_result.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../data_sources/search_remote_data_source.dart';
import '../data_sources/search_signalr_data_source.dart';
import 'visual_search_repo.dart';

class VisualSearchRepoImpl implements VisualSearchRepo {
  VisualSearchRepoImpl(
    this._remote,
    this._signalR,
    this._prefs,
  );

  final SearchRemoteDataSource _remote;
  final SearchSignalRDataSource _signalR;
  final UserPreferencesService _prefs;

  @override
  Future<ImageSearchResult> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? countryCode,
  }) =>
      _remote.uploadImage(
        bytes: bytes,
        fileName: fileName,
        countryCode: countryCode ?? _prefs.preferredCountry,
      );

  @override
  Future<void> startOffersSearch(String requestId, {String? countryCode}) =>
      _remote.startOffersSearch(
        requestId,
        countryCode: countryCode ?? _prefs.preferredCountry,
      );

  @override
  Future<RankedOffersResult> getOffers(String requestId) =>
      _remote.getOffers(requestId);

  @override
  Stream<AffiliateProductOffer> watchOffers() => _signalR.offers;

  @override
  Stream<OffersSearchSummary?> watchSearchCompleted() =>
      _signalR.searchCompleted;

  @override
  Future<void> connectStream({
    required String requestId,
    required void Function(double) onProgress,
  }) =>
      _signalR.connectAndJoin(requestId: requestId, onProgress: onProgress);

  @override
  Future<void> disconnectStream(String requestId) async {
    await _signalR.leaveGroup(requestId);
    await _signalR.disconnect();
  }

  @override
  Future<String?> prepareBuyLink({
    required String requestId,
    required String offerId,
  }) async {
    try {
      return await _remote.preparePurchaseRedirect(
        requestId: requestId,
        offerId: offerId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String getPreferredCountry() => _prefs.preferredCountry;
}
