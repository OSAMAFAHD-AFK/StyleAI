import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/image_search_result.dart';
import '../models/ranked_offers_result.dart';
import '../models/thrift_counter_summary.dart';
import '../utils/api_service.dart';

class SearchApiService {
  SearchApiService(this._api);

  final ApiService _api;

  Future<ImageSearchResult> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? countryCode,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _api.client.post<Map<String, dynamic>>(
      '/api/search/upload',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: countryCode != null
            ? <String, dynamic>{'X-Country-Code': countryCode}
            : null,
      ),
    );

    return ImageSearchResult.fromJson(response.data!);
  }

  Future<ImageSearchResult> getSearchResult(String requestId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/search/$requestId/result',
    );
    return ImageSearchResult.fromJson(response.data!);
  }

  Future<void> startOffersSearch(String requestId, {String? countryCode}) async {
    await _api.client.post<void>(
      '/api/search/$requestId/offers/start',
      options: Options(
        headers: countryCode != null
            ? <String, dynamic>{'X-Country-Code': countryCode}
            : null,
      ),
    );
  }

  Future<RankedOffersResult> getOffers(String requestId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/search/$requestId/offers',
    );
    return RankedOffersResult.fromJson(response.data!);
  }

  Future<ThriftCounterSummary> getThriftSummary() async {
    final response = await _api.get<Map<String, dynamic>>('/api/thrift/summary');
    return ThriftCounterSummary.fromJson(response.data!);
  }

  Future<String> preparePurchaseRedirect({
    required String requestId,
    required String offerId,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/redirect/prepare',
      data: {'requestId': requestId, 'offerId': offerId},
    );
    return response.data!['redirectUrl'] as String;
  }
}
