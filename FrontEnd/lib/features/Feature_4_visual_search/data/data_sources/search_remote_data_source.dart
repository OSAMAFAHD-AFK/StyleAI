import 'dart:typed_data';

import '../../../../core/models/image_search_result.dart';
import '../../../../core/models/ranked_offers_result.dart';
import '../../../../core/services/search_api_service.dart';

class SearchRemoteDataSource {
  SearchRemoteDataSource(this._api);

  final SearchApiService _api;

  Future<ImageSearchResult> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? countryCode,
  }) =>
      _api.uploadImage(bytes: bytes, fileName: fileName, countryCode: countryCode);

  Future<void> startOffersSearch(String requestId, {String? countryCode}) =>
      _api.startOffersSearch(requestId, countryCode: countryCode);

  Future<RankedOffersResult> getOffers(String requestId) =>
      _api.getOffers(requestId);

  Future<String> preparePurchaseRedirect({
    required String requestId,
    required String offerId,
  }) =>
      _api.preparePurchaseRedirect(requestId: requestId, offerId: offerId);
}
