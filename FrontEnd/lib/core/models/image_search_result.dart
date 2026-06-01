import 'package:equatable/equatable.dart';

import 'bounding_box.dart';
import 'garment_tags.dart';

/// Mirrors [ImageSearchResult] from the .NET API upload/result responses.
class ImageSearchResult extends Equatable {
  const ImageSearchResult({
    required this.requestId,
    this.boundingBox,
    this.confidence,
    this.detectorVersion,
    this.originalWidth,
    this.originalHeight,
    this.processedWidth,
    this.processedHeight,
    this.processingMilliseconds,
    this.croppedImageBase64,
    this.tags,
    this.tagsStatus,
    this.searchLogId,
    this.geminiModelVersion,
    this.message,
  });

  final String requestId;
  final BoundingBox? boundingBox;
  final double? confidence;
  final String? detectorVersion;
  final int? originalWidth;
  final int? originalHeight;
  final int? processedWidth;
  final int? processedHeight;
  final int? processingMilliseconds;
  final String? croppedImageBase64;
  final GarmentTags? tags;
  final String? tagsStatus;
  final int? searchLogId;
  final String? geminiModelVersion;
  final String? message;

  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    return ImageSearchResult(
      requestId: json['requestId'] as String? ?? '',
      boundingBox: json['boundingBox'] != null
          ? BoundingBox.fromJson(json['boundingBox'] as Map<String, dynamic>)
          : null,
      confidence: (json['confidence'] as num?)?.toDouble(),
      detectorVersion: json['detectorVersion'] as String?,
      originalWidth: (json['originalWidth'] as num?)?.toInt(),
      originalHeight: (json['originalHeight'] as num?)?.toInt(),
      processedWidth: (json['processedWidth'] as num?)?.toInt(),
      processedHeight: (json['processedHeight'] as num?)?.toInt(),
      processingMilliseconds: (json['processingMilliseconds'] as num?)?.toInt(),
      croppedImageBase64: json['croppedImageBase64'] as String?,
      tags: json['tags'] != null
          ? GarmentTags.fromJson(json['tags'] as Map<String, dynamic>)
          : null,
      tagsStatus: json['tagsStatus'] as String?,
      searchLogId: (json['searchLogId'] as num?)?.toInt(),
      geminiModelVersion: json['geminiModelVersion'] as String?,
      message: json['message'] as String?,
    );
  }

  @override
  List<Object?> get props => [requestId, tagsStatus];
}
