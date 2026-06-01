import 'package:equatable/equatable.dart';

/// Mirrors [AffiliateProductOffer] from StyleAI.Application.Features.Affiliate.Models.
class AffiliateProductOffer extends Equatable {
  const AffiliateProductOffer({
    required this.offerId,
    required this.requestId,
    required this.provider,
    required this.title,
    this.description,
    required this.merchantName,
    required this.merchantSlug,
    required this.comparisonTitle,
    required this.productUrl,
    this.imageUrl,
    this.imageUrls,
    required this.price,
    required this.currency,
    required this.localizedPrice,
    required this.localizedCurrency,
    required this.normalizedColor,
    this.normalizedSize,
    required this.sourceCountry,
    required this.sequenceNumber,
    this.offerKind = 'dupe',
    this.isBenchmark = false,
    this.savedAmount,
    this.savingsPercent,
    this.displayRank = 0,
  });

  final String offerId;
  final String requestId;
  final String provider;
  final String title;
  final String? description;
  final String merchantName;
  final String merchantSlug;
  final String comparisonTitle;
  final String productUrl;
  final String? imageUrl;
  final List<String>? imageUrls;
  final double price;
  final String currency;
  final double localizedPrice;
  final String localizedCurrency;
  final String normalizedColor;
  final String? normalizedSize;
  final String sourceCountry;
  final int sequenceNumber;
  final String offerKind;
  final bool isBenchmark;
  final double? savedAmount;
  final double? savingsPercent;
  final int displayRank;

  List<String> get galleryImages {
    if (imageUrls != null && imageUrls!.isNotEmpty) return imageUrls!;
    if (imageUrl != null && imageUrl!.isNotEmpty) return [imageUrl!];
    return const [];
  }

  factory AffiliateProductOffer.fromJson(Map<String, dynamic> json) {
    return AffiliateProductOffer(
      offerId: json['offerId'] as String? ?? '',
      requestId: json['requestId'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      merchantName: json['merchantName'] as String? ?? '',
      merchantSlug: json['merchantSlug'] as String? ?? '',
      comparisonTitle: json['comparisonTitle'] as String? ?? '',
      productUrl: json['productUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      localizedPrice: (json['localizedPrice'] as num?)?.toDouble() ?? 0,
      localizedCurrency: json['localizedCurrency'] as String? ?? 'USD',
      normalizedColor: json['normalizedColor'] as String? ?? '',
      normalizedSize: json['normalizedSize'] as String?,
      sourceCountry: json['sourceCountry'] as String? ?? '',
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
      offerKind: json['offerKind'] as String? ?? 'dupe',
      isBenchmark: json['isBenchmark'] as bool? ?? false,
      savedAmount: (json['savedAmount'] as num?)?.toDouble(),
      savingsPercent: (json['savingsPercent'] as num?)?.toDouble(),
      displayRank: (json['displayRank'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [offerId, requestId];
}
