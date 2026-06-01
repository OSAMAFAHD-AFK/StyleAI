import '../../../../core/models/affiliate_product_offer.dart';
import '../../../../core/models/offers_search_summary.dart';
import '../../../../core/models/ranked_offers_result.dart';
import '../../../../core/utils/mock_catalog.dart';

/// Demo offers when the backend is unavailable or for preview flows.
abstract final class SearchMockDataSource {
  static const demoRequestId = 'demo-search';

  static bool isDemoRequestId(String requestId) =>
      requestId.startsWith('demo-') || requestId == demoRequestId;

  static ({String title, String imageUrl})? featuredForRequest(String requestId) {
    return switch (requestId) {
      'demo-search-handbag' => (title: 'Luxury Handbag', imageUrl: MockCatalog.handbag),
      'demo-search-silk-dress' => (title: 'Silk Dress', imageUrl: MockCatalog.silkDress),
      'demo-search-blazer' => (title: 'Summer Blazer', imageUrl: MockCatalog.blazer),
      'demo-search-evening-gown' => (title: 'Evening Gown', imageUrl: MockCatalog.eveningGown),
      'demo-search-sneakers' => (title: 'Premium Sneakers', imageUrl: MockCatalog.sneakers),
      _ => null,
    };
  }

  /// Set to false once the backend returns real offers.
  static const usePreviewData = true;

  /// Mock circle: 0 → 20 → 40 → 60 → 80 → 100 (5 jumps). Text keeps its own pace.
  static const processingStepDelay = Duration(milliseconds: 900);
  static const processingMessageDelay = Duration(seconds: 3);
  static const processingStepCount = 5;
  static const processingProgressSteps = [0.2, 0.4, 0.6, 0.8, 1.0];

  static RankedOffersResult buildResults(String requestId) {
    const currency = 'SAR';
    final featured = featuredForRequest(requestId);

    AffiliateProductOffer offer({
      required String id,
      required String title,
      required String merchant,
      required String imageUrl,
      required double price,
      required double original,
      required int savings,
      required String kind,
      required int rank,
    }) {
      return AffiliateProductOffer(
        offerId: id,
        requestId: requestId,
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
        sequenceNumber: rank,
        offerKind: kind,
        savedAmount: original - price,
        savingsPercent: savings.toDouble(),
        displayRank: rank,
      );
    }

    final originals = [
      offer(
        id: 'orig-1',
        title: featured?.title ?? 'Evening Dress — Silk',
        merchant: 'Namshi',
        imageUrl: featured?.imageUrl ?? MockCatalog.eveningGown,
        price: 245,
        original: 1120,
        savings: 78,
        kind: 'original',
        rank: 1,
      ),
      offer(
        id: 'orig-2',
        title: 'Structured Blazer',
        merchant: 'ASOS',
        imageUrl: MockCatalog.blazer,
        price: 189,
        original: 650,
        savings: 71,
        kind: 'original',
        rank: 2,
      ),
      offer(
        id: 'orig-3',
        title: 'Silk Midi Dress',
        merchant: 'Zara',
        imageUrl: MockCatalog.silkDress,
        price: 210,
        original: 890,
        savings: 76,
        kind: 'original',
        rank: 3,
      ),
      offer(
        id: 'orig-4',
        title: 'Classic Tote Bag',
        merchant: 'Farfetch',
        imageUrl: MockCatalog.handbag,
        price: 320,
        original: 1450,
        savings: 78,
        kind: 'original',
        rank: 4,
      ),
      offer(
        id: 'orig-5',
        title: 'Floral Maxi Dress',
        merchant: 'Mango',
        imageUrl: MockCatalog.dress,
        price: 175,
        original: 720,
        savings: 76,
        kind: 'original',
        rank: 5,
      ),
      offer(
        id: 'orig-6',
        title: 'Premium Sneakers',
        merchant: 'Nike',
        imageUrl: MockCatalog.sneakers,
        price: 399,
        original: 1299,
        savings: 69,
        kind: 'original',
        rank: 6,
      ),
    ];

    final dupes = [
      offer(
        id: 'dupe-1',
        title: 'Sparkle Heels',
        merchant: 'Shein',
        imageUrl: MockCatalog.sneakers,
        price: 89,
        original: 420,
        savings: 79,
        kind: 'dupe',
        rank: 7,
      ),
      offer(
        id: 'dupe-2',
        title: 'Silk Slip Dress',
        merchant: 'Zara',
        imageUrl: MockCatalog.silkDress,
        price: 120,
        original: 580,
        savings: 79,
        kind: 'dupe',
        rank: 8,
      ),
      offer(
        id: 'dupe-3',
        title: 'Evening Gown Lookalike',
        merchant: 'H&M',
        imageUrl: MockCatalog.dress,
        price: 95,
        original: 490,
        savings: 81,
        kind: 'dupe',
        rank: 9,
      ),
      offer(
        id: 'dupe-4',
        title: 'Tailored Blazer Dupe',
        merchant: 'Boohoo',
        imageUrl: MockCatalog.blazer,
        price: 72,
        original: 380,
        savings: 81,
        kind: 'dupe',
        rank: 10,
      ),
      offer(
        id: 'dupe-5',
        title: 'Mini Crossbody Bag',
        merchant: 'AliExpress',
        imageUrl: MockCatalog.handbag,
        price: 45,
        original: 260,
        savings: 83,
        kind: 'dupe',
        rank: 11,
      ),
      offer(
        id: 'dupe-6',
        title: 'Satin Party Dress',
        merchant: 'PrettyLittleThing',
        imageUrl: MockCatalog.eveningGown,
        price: 68,
        original: 340,
        savings: 80,
        kind: 'dupe',
        rank: 12,
      ),
    ];

    return RankedOffersResult(
      requestId: requestId,
      originals: originals,
      dupes: dupes,
      summary: const OffersSearchSummary(
        totalOffers: 12,
        originalCount: 6,
        dupeCount: 6,
        currency: currency,
        maxSavingsPercent: 80,
      ),
      status: 'completed',
    );
  }
}
