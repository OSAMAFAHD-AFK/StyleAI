import 'package:equatable/equatable.dart';

class ThriftCounterSummary extends Equatable {
  const ThriftCounterSummary({
    required this.userId,
    required this.totalSavings,
    required this.currency,
    required this.totalClicks,
    required this.convertedClicks,
  });

  final String userId;
  final double totalSavings;
  final String currency;
  final int totalClicks;
  final int convertedClicks;

  factory ThriftCounterSummary.fromJson(Map<String, dynamic> json) {
    return ThriftCounterSummary(
      userId: json['userId'] as String? ?? '',
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      totalClicks: (json['totalClicks'] as num?)?.toInt() ?? 0,
      convertedClicks: (json['convertedClicks'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [userId, totalSavings];
}
