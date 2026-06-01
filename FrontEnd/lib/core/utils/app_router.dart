import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/Feature_1_splash/presentation/manager/auth_cubit.dart';
import '../../features/Feature_1_splash/presentation/views/splash_view.dart';
import '../../features/Feature_2_profile_setup/presentation/manager/profile_setup_cubit.dart';
import '../../features/Feature_2_profile_setup/presentation/views/profile_setup_view.dart';
import '../../features/Feature_3_home/presentation/manager/home_cubit.dart';
import '../../features/Feature_3_home/presentation/views/home_view.dart';
import '../../features/Feature_4_visual_search/presentation/manager/search_flow_cubit.dart';
import '../../features/Feature_4_visual_search/presentation/views/capture_analysis_view.dart';
import '../../features/Feature_4_visual_search/presentation/views/processing_view.dart';
import '../../features/Feature_4_visual_search/presentation/views/scanner_view.dart';
import '../../features/Feature_4_visual_search/presentation/views/search_results_view.dart';
import '../../features/Feature_5_collections/presentation/manager/collections_cubit.dart';
import '../../features/Feature_5_collections/presentation/utils/collections_navigation.dart';
import '../../features/Feature_5_collections/presentation/views/collections_view.dart';
import '../../features/Feature_6_profile/presentation/manager/profile_cubit.dart';
import '../../features/Feature_6_profile/presentation/views/profile_view.dart';
import '../services/user_preferences_service.dart';
import '../widgets/main_shell.dart';
import 'service_locator.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const searchTab = '/search';
  static const scanner = '/scanner';
  static const processing = '/processing';
  static const searchResults = '/search/results';

  static String searchResultsFor(String requestId) => '$searchResults/$requestId';
  static const collections = '/collections';
  static const profile = '/profile';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: sl<UserPreferencesService>(),
    redirect: (context, state) {
      final prefs = sl<UserPreferencesService>();
      final location = state.matchedLocation;
      final onSplash = location == AppRoutes.splash;
      final onSetup = location == AppRoutes.profileSetup;

      if (!prefs.isProfileCompleted && !onSplash && !onSetup) {
        return AppRoutes.profileSetup;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(sl()),
          child: const SplashView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => BlocProvider(
          create: (_) => ProfileSetupCubit(sl()),
          child: const ProfileSetupView(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => BlocProvider(
              create: (_) => HomeCubit(sl())..load(),
              child: const HomeView(),
            ),
          ),
          GoRoute(
            path: AppRoutes.searchTab,
            builder: (context, state) {
              final cubit = sl<SearchFlowCubit>();
              cubit.applyRouteExtra(state.extra);
              return BlocProvider.value(
                value: cubit,
                child: const CaptureAnalysisView(),
              );
            },
            routes: [
              GoRoute(
                path: 'results/:requestId',
                builder: (context, state) {
                  final requestId = state.pathParameters['requestId']!;
                  final cubit = sl<SearchFlowCubit>();
                  if (cubit.state.requestId != requestId ||
                      cubit.state.rankedResult == null) {
                    cubit.loadResults(requestId);
                  }
                  return BlocProvider.value(
                    value: cubit,
                    child: SearchResultsView(requestId: requestId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.collections,
            builder: (context, state) {
              final tabIndex = CollectionsNavigation.tabIndexFrom(state);
              return BlocProvider(
                create: (_) => CollectionsCubit(sl(), initialTabIndex: tabIndex)..load(),
                child: const CollectionsView(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => BlocProvider(
              create: (_) => ProfileCubit(sl())..load(),
              child: const ProfileView(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.scanner,
        builder: (context, state) => const ScannerView(),
      ),
      GoRoute(
        path: '${AppRoutes.processing}/:requestId',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return BlocProvider.value(
            value: sl<SearchFlowCubit>(),
            child: ProcessingView(requestId: requestId),
          );
        },
      ),
    ],
  );
}
