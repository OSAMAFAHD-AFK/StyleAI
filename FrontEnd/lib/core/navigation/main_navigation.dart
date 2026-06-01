import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/Feature_4_visual_search/presentation/utils/search_navigation.dart';
import '../utils/app_router.dart';
import '../widgets/glass_bottom_nav_bar.dart';

/// Central navigation for the main tab shell and full-screen flows.
abstract final class MainNavigation {
  static MainNavItem itemFromPath(String path) {
    if (path.startsWith(AppRoutes.home)) return MainNavItem.home;
    if (path.startsWith(AppRoutes.searchTab)) return MainNavItem.search;
    if (path.startsWith(AppRoutes.collections)) return MainNavItem.discover;
    if (path.startsWith(AppRoutes.profile)) return MainNavItem.profile;
    return MainNavItem.home;
  }

  static void onTabSelected(BuildContext context, MainNavItem item) {
    switch (item) {
      case MainNavItem.home:
        context.go(AppRoutes.home);
      case MainNavItem.search:
        SearchNavigation.openSearchTab(context);
      case MainNavItem.scan:
        context.push(AppRoutes.scanner);
      case MainNavItem.discover:
        context.go(AppRoutes.collections);
      case MainNavItem.profile:
        context.go(AppRoutes.profile);
    }
  }
}
