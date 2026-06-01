import 'package:equatable/equatable.dart';

import 'affiliate_product_offer.dart';
import 'offers_search_summary.dart';

class RankedOffersResult extends Equatable {
  const RankedOffersResult({
    required this.requestId,
    this.benchmark,
    this.originals = const [],
    this.dupes = const [],
    this.priceMatches = const [],
    this.summary,
    this.allOffers = const [],
    this.status,
  });

  final String requestId;
  final AffiliateProductOffer? benchmark;
  final List<AffiliateProductOffer> originals;
  final List<AffiliateProductOffer> dupes;
  final List<AffiliateProductOffer> priceMatches;
  final OffersSearchSummary? summary;
  final List<AffiliateProductOffer> allOffers;
  final String? status;

  factory RankedOffersResult.fromJson(Map<String, dynamic> json) {
    List<AffiliateProductOffer> parseList(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => AffiliateProductOffer.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return RankedOffersResult(
      requestId: json['requestId'] as String? ?? '',
      benchmark: json['benchmark'] != null
          ? AffiliateProductOffer.fromJson(
              json['benchmark'] as Map<String, dynamic>,
            )
          : null,
      originals: parseList('originals'),
      dupes: parseList('dupes'),
      priceMatches: parseList('priceMatches'),
      summary: json['summary'] != null
          ? OffersSearchSummary.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : null,
      allOffers: parseList('offers'),
      status: json['status'] as String?,
    );
  }

  @override
  List<Object?> get props => [requestId, status];
}
