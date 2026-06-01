import '../../../../core/models/affiliate_product_offer.dart';
import '../../../../core/models/offers_search_summary.dart';
import '../../../../core/services/search_offers_signalr_service.dart';

class SearchSignalRDataSource {
  SearchSignalRDataSource(this._signalR);

  final SearchOffersSignalRService _signalR;

  Stream<AffiliateProductOffer> get offers => _signalR.offers;

  Stream<OffersSearchSummary?> get searchCompleted => _signalR.searchCompleted;

  Future<void> connectAndJoin({
    required String requestId,
    required void Function(double) onProgress,
  }) =>
      _signalR.connectAndJoin(requestId: requestId, onProgress: onProgress);

  Future<void> leaveGroup(String requestId) => _signalR.leaveGroup(requestId);

  Future<void> disconnect() => _signalR.disconnect();
}
