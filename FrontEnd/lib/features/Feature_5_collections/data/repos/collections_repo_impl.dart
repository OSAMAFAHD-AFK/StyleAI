import '../../../../core/models/affiliate_product_offer.dart';
import '../data_sources/collections_mock_data_source.dart';
import '../models/search_history_item_model.dart';
import 'collections_repo.dart';

class CollectionsRepoImpl implements CollectionsRepo {
  CollectionsRepoImpl(this._mock);

  final CollectionsMockDataSource _mock;

  @override
  List<AffiliateProductOffer> getSavedOffers() => _mock.fetchSavedOffers();

  @override
  void removeSavedOffer(String offerId) => _mock.removeSavedOffer(offerId);

  @override
  List<SearchHistoryItemModel> getSearchHistory() => _mock.fetchSearchHistory();
}
