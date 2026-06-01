import '../../../../core/services/device_token_service.dart';

class LocalAuthDataSource {
  LocalAuthDataSource(this._deviceTokenService);

  final DeviceTokenService _deviceTokenService;

  Future<String> ensureDeviceToken() => _deviceTokenService.getOrCreateToken();
}
