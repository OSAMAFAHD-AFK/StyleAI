import '../../../../core/models/thrift_counter_summary.dart';
import '../../../Feature_5_collections/data/models/search_history_item_model.dart';

abstract class HomeRepo {
  ThriftCounterSummary getCachedThriftSummary();
  Future<ThriftCounterSummary> getThriftSummary();
  List<SearchHistoryItemModel> getRecentSearchResults();
  String getDisplayName();
  String getGender();
}
