import '../../../../core/models/affiliate_product_offer.dart';
import '../models/search_history_item_model.dart';

abstract class CollectionsRepo {
  List<AffiliateProductOffer> getSavedOffers();
  void removeSavedOffer(String offerId);
  List<SearchHistoryItemModel> getSearchHistory();
}
