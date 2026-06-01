import '../../../../core/models/thrift_counter_summary.dart';
import '../../../../core/services/search_api_service.dart';

class ThriftRemoteDataSource {
  ThriftRemoteDataSource(this._api);

  final SearchApiService _api;

  Future<ThriftCounterSummary> fetchSummary() => _api.getThriftSummary();
}
