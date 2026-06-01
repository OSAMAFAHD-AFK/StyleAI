import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/main_navigation.dart';
import '../utils/app_colors.dart';
import 'glass_bottom_nav_bar.dart';

/// Wraps main tab routes with a shared glass bottom navigation bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final current = MainNavigation.itemFromPath(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNavBar(
              current: current,
              onTap: (item) => MainNavigation.onTabSelected(context, item),
            ),
          ),
        ],
      ),
    );
  }
}
