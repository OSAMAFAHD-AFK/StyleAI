import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/Feature_1_splash/data/data_sources/local_auth_data_source.dart';
import '../../features/Feature_1_splash/data/repos/auth_repo.dart';
import '../../features/Feature_1_splash/data/repos/auth_repo_impl.dart';
import '../../features/Feature_2_profile_setup/data/data_sources/local_profile_data_source.dart';
import '../../features/Feature_2_profile_setup/data/repos/profile_setup_repo.dart';
import '../../features/Feature_2_profile_setup/data/repos/profile_setup_repo_impl.dart';
import '../../features/Feature_3_home/data/data_sources/thrift_remote_data_source.dart';
import '../../features/Feature_3_home/data/repos/home_repo.dart';
import '../../features/Feature_3_home/data/repos/home_repo_impl.dart';
import '../../features/Feature_4_visual_search/data/data_sources/search_remote_data_source.dart';
import '../../features/Feature_4_visual_search/data/data_sources/search_signalr_data_source.dart';
import '../../features/Feature_4_visual_search/presentation/manager/search_flow_cubit.dart';
import '../../features/Feature_4_visual_search/data/repos/visual_search_repo.dart';
import '../../features/Feature_4_visual_search/data/repos/visual_search_repo_impl.dart';
import '../../features/Feature_5_collections/data/data_sources/collections_mock_data_source.dart';
import '../../features/Feature_5_collections/data/repos/collections_repo.dart';
import '../../features/Feature_5_collections/data/repos/collections_repo_impl.dart';
import '../../features/Feature_6_profile/data/data_sources/profile_local_data_source.dart';
import '../../features/Feature_6_profile/data/repos/profile_repo.dart';
import '../../features/Feature_6_profile/data/repos/profile_repo_impl.dart';
import '../services/device_token_service.dart';
import '../services/search_api_service.dart';
import '../services/search_offers_signalr_service.dart';
import '../services/user_preferences_service.dart';
import 'api_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton(() => DeviceTokenService(sl()));
  sl.registerLazySingleton(() => UserPreferencesService(sl()));
  sl.registerLazySingleton(() => ApiService(deviceTokenService: sl()));
  sl.registerLazySingleton(() => SearchApiService(sl()));
  sl.registerFactory(() => SearchOffersSignalRService());

  // Data sources
  sl.registerLazySingleton(() => LocalAuthDataSource(sl()));
  sl.registerLazySingleton(() => LocalProfileDataSource(sl(), sl()));
  sl.registerLazySingleton(() => ThriftRemoteDataSource(sl()));
  sl.registerLazySingleton(() => SearchRemoteDataSource(sl()));
  sl.registerFactory(() => SearchSignalRDataSource(sl()));
  sl.registerLazySingleton(() => CollectionsMockDataSource());
  sl.registerLazySingleton(() => ProfileLocalDataSource(sl(), sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));
  sl.registerLazySingleton<ProfileSetupRepo>(() => ProfileSetupRepoImpl(sl()));
  sl.registerLazySingleton<HomeRepo>(() => HomeRepoImpl(sl(), sl(), sl()));
  sl.registerLazySingleton<SearchFlowCubit>(() => SearchFlowCubit(sl()));
  sl.registerFactory<VisualSearchRepo>(
    () => VisualSearchRepoImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CollectionsRepo>(() => CollectionsRepoImpl(sl()));
  sl.registerLazySingleton<ProfileRepo>(() => ProfileRepoImpl(sl()));
}
