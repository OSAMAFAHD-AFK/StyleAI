import 'package:dio/dio.dart';

import '../services/device_token_service.dart';
import 'app_constants.dart';

/// Central HTTP client — injects device & country headers for all API calls.
class ApiService {
  ApiService({
    required DeviceTokenService deviceTokenService,
    String? baseUrl,
  })  : _deviceTokenService = deviceTokenService,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 120),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _deviceTokenService.getOrCreateToken();
          options.headers['X-Device-Token'] = token;
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final DeviceTokenService _deviceTokenService;

  Dio get client => _dio;

  void setCountryCode(String countryCode) {
    _dio.options.headers['X-Country-Code'] = countryCode;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, options: options);
}
