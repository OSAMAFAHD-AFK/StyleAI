import '../models/search_history_item_model.dart';
import '../../../../core/models/affiliate_product_offer.dart';
import '../../../../core/utils/mock_catalog.dart';

class CollectionsMockDataSource {
  CollectionsMockDataSource() {
    _savedOffers.addAll(_initialSavedOffers());
  }

  final List<AffiliateProductOffer> _savedOffers = [];

  List<AffiliateProductOffer> fetchSavedOffers() =>
      List<AffiliateProductOffer>.unmodifiable(_savedOffers);

  void removeSavedOffer(String offerId) {
    _savedOffers.removeWhere((offer) => offer.offerId == offerId);
  }

  static List<AffiliateProductOffer> _initialSavedOffers() {
    const currency = 'SAR';

    AffiliateProductOffer offer({
      required String id,
      required String title,
      required String merchant,
      required String imageUrl,
      required double price,
      required double original,
      required int savings,
    }) {
      return AffiliateProductOffer(
        offerId: id,
        requestId: 'saved',
        provider: 'mock',
        title: title,
        merchantName: merchant,
        merchantSlug: merchant.toLowerCase(),
        comparisonTitle: title,
        productUrl: 'https://example.com/$id',
        imageUrl: imageUrl,
        imageUrls: MockCatalog.galleryFor(imageUrl),
        price: price,
        currency: currency,
        localizedPrice: price,
        localizedCurrency: currency,
        normalizedColor: 'Black',
        sourceCountry: 'SA',
        sequenceNumber: 1,
        offerKind: 'original',
        savedAmount: original - price,
        savingsPercent: savings.toDouble(),
        displayRank: 1,
      );
    }

    return [
      offer(
        id: 'saved-1',
        title: 'Evening Dress — Silk',
        merchant: 'Namshi',
        imageUrl: MockCatalog.eveningGown,
        price: 245,
        original: 1120,
        savings: 78,
      ),
      offer(
        id: 'saved-2',
        title: 'Structured Blazer',
        merchant: 'ASOS',
        imageUrl: MockCatalog.blazer,
        price: 189,
        original: 650,
        savings: 71,
      ),
      offer(
        id: 'saved-3',
        title: 'Classic Tote Bag',
        merchant: 'Farfetch',
        imageUrl: MockCatalog.handbag,
        price: 320,
        original: 1450,
        savings: 78,
      ),
      offer(
        id: 'saved-4',
        title: 'Premium Sneakers',
        merchant: 'Nike',
        imageUrl: MockCatalog.sneakers,
        price: 399,
        original: 1299,
        savings: 69,
      ),
    ];
  }

  List<SearchHistoryItemModel> fetchSearchHistory() {
    return const [
      SearchHistoryItemModel(
        requestId: 'demo-search-handbag',
        timestampLabel: 'Today, 10:30 AM',
        title: 'Luxury Handbag',
        resultSummary: '12 similar pieces found',
        searchType: 'AI Scan',
        imageUrl: MockCatalog.handbag,
      ),
      SearchHistoryItemModel(
        requestId: 'demo-search-silk-dress',
        timestampLabel: 'Yesterday',
        title: 'Silk Dress',
        resultSummary: '8 similar pieces found',
        searchType: 'AI Scan',
        imageUrl: MockCatalog.silkDress,
      ),
      SearchHistoryItemModel(
        requestId: 'demo-search-blazer',
        timestampLabel: '3 April',
        title: 'Summer Blazer',
        resultSummary: '15 similar pieces found',
        searchType: 'Upload',
        imageUrl: MockCatalog.blazer,
      ),
      SearchHistoryItemModel(
        requestId: 'demo-search-evening-gown',
        timestampLabel: '28 March',
        title: 'Evening Gown',
        resultSummary: '10 similar pieces found',
        searchType: 'AI Scan',
        imageUrl: MockCatalog.eveningGown,
      ),
      SearchHistoryItemModel(
        requestId: 'demo-search-sneakers',
        timestampLabel: '22 March',
        title: 'Premium Sneakers',
        resultSummary: '18 similar pieces found',
        searchType: 'Upload',
        imageUrl: MockCatalog.sneakers,
      ),
    ];
  }
}
