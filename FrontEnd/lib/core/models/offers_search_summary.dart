import 'package:equatable/equatable.dart';

class OffersSearchSummary extends Equatable {
  const OffersSearchSummary({
    this.benchmarkLocalizedPrice,
    this.cheapestDupeLocalizedPrice,
    this.maxSavings,
    this.maxSavingsPercent,
    this.currency = 'USD',
    this.totalOffers = 0,
    this.originalCount = 0,
    this.dupeCount = 0,
  });

  final double? benchmarkLocalizedPrice;
  final double? cheapestDupeLocalizedPrice;
  final double? maxSavings;
  final double? maxSavingsPercent;
  final String currency;
  final int totalOffers;
  final int originalCount;
  final int dupeCount;

  factory OffersSearchSummary.fromJson(Map<String, dynamic> json) {
    return OffersSearchSummary(
      benchmarkLocalizedPrice:
          (json['benchmarkLocalizedPrice'] as num?)?.toDouble(),
      cheapestDupeLocalizedPrice:
          (json['cheapestDupeLocalizedPrice'] as num?)?.toDouble(),
      maxSavings: (json['maxSavings'] as num?)?.toDouble(),
      maxSavingsPercent: (json['maxSavingsPercent'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      totalOffers: (json['totalOffers'] as num?)?.toInt() ?? 0,
      originalCount: (json['originalCount'] as num?)?.toInt() ?? 0,
      dupeCount: (json['dupeCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalOffers, currency];
}
