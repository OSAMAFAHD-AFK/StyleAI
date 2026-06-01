import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';

abstract final class CollectionsNavigation {
  static const searchResultsTab = 0;
  static const savedTab = 1;

  static void openSearchResults(BuildContext context) {
    context.go('${AppRoutes.collections}?tab=$searchResultsTab');
  }

  static int tabIndexFrom(GoRouterState state) {
    final tab = state.uri.queryParameters['tab'];
    if (tab == '0' || tab == 'search') return searchResultsTab;
    return savedTab;
  }
}
