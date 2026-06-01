import 'package:equatable/equatable.dart';

/// Mirrors [GarmentTags] from StyleAI.Application.Features.Search.Models.
class GarmentTags extends Equatable {
  const GarmentTags({
    required this.category,
    required this.color,
    required this.style,
  });

  final String category;
  final String color;
  final String style;

  factory GarmentTags.fromJson(Map<String, dynamic> json) {
    return GarmentTags(
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      style: json['style'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'color': color,
        'style': style,
      };

  @override
  List<Object?> get props => [category, color, style];
}
