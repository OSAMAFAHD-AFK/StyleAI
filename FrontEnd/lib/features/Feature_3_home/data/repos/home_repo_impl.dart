import '../../../../core/models/thrift_counter_summary.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../../../Feature_5_collections/data/models/search_history_item_model.dart';
import '../../../Feature_5_collections/data/repos/collections_repo.dart';
import '../../core/home_constants.dart';
import '../data_sources/thrift_remote_data_source.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  HomeRepoImpl(
    this._thriftRemote,
    this._collectionsRepo,
    this._prefs,
  );

  final ThriftRemoteDataSource _thriftRemote;
  final CollectionsRepo _collectionsRepo;
  final UserPreferencesService _prefs;

  static const _defaultThrift = ThriftCounterSummary(
    userId: '',
    totalSavings: 430,
    currency: 'USD',
    totalClicks: 0,
    convertedClicks: 0,
  );

  @override
  ThriftCounterSummary getCachedThriftSummary() {
    return _prefs.cachedThriftSummary ?? _defaultThrift;
  }

  @override
  Future<ThriftCounterSummary> getThriftSummary() async {
    try {
      final summary = await _thriftRemote.fetchSummary();
      await _prefs.saveThriftSummary(summary);
      return summary;
    } catch (_) {
      return getCachedThriftSummary();
    }
  }

  @override
  List<SearchHistoryItemModel> getRecentSearchResults() {
    return _collectionsRepo
        .getSearchHistory()
        .take(HomeConstants.recentSearchPreviewLimit)
        .toList();
  }

  @override
  String getDisplayName() => _prefs.displayName;

  @override
  String getGender() => _prefs.gender;
}
