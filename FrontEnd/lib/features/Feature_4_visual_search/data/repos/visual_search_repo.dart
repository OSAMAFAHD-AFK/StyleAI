import 'dart:typed_data';

import '../../../../core/models/affiliate_product_offer.dart';
import '../../../../core/models/image_search_result.dart';
import '../../../../core/models/offers_search_summary.dart';
import '../../../../core/models/ranked_offers_result.dart';

abstract class VisualSearchRepo {
  Future<ImageSearchResult> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? countryCode,
  });

  Future<void> startOffersSearch(String requestId, {String? countryCode});

  Future<RankedOffersResult> getOffers(String requestId);

  Stream<AffiliateProductOffer> watchOffers();

  Stream<OffersSearchSummary?> watchSearchCompleted();

  Future<void> connectStream({
    required String requestId,
    required void Function(double) onProgress,
  });

  Future<void> disconnectStream(String requestId);

  Future<String?> prepareBuyLink({
    required String requestId,
    required String offerId,
  });

  String getPreferredCountry();
}
