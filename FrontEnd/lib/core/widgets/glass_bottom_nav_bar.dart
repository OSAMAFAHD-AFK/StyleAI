import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../l10n/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/style.dart';

enum MainNavItem { home, search, scan, discover, profile }

class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({
    super.key,
    required this.current,
    required this.onTap,
  });

  final MainNavItem current;
  final ValueChanged<MainNavItem> onTap;

  /// Extra bottom padding so scrollable tab content clears the floating nav pill.
  static double contentBottomInset(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return 22.h + safeBottom + 72.h;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 22.h),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavTab(
                        icon: Icons.home_rounded,
                        label: AppStrings.home,
                        active: current == MainNavItem.home,
                        onTap: () => onTap(MainNavItem.home),
                      ),
                    ),
                    Expanded(
                      child: _NavTab(
                        icon: Icons.search_rounded,
                        label: AppStrings.search,
                        active: current == MainNavItem.search,
                        onTap: () => onTap(MainNavItem.search),
                      ),
                    ),
                    Expanded(
                      child: _ScanTab(
                        active: current == MainNavItem.scan,
                        onTap: () => onTap(MainNavItem.scan),
                      ),
                    ),
                    Expanded(
                      child: _NavTab(
                        icon: Icons.explore_rounded,
                        label: AppStrings.discover,
                        active: current == MainNavItem.discover,
                        onTap: () => onTap(MainNavItem.discover),
                      ),
                    ),
                    Expanded(
                      child: _NavTab(
                        icon: Icons.person_rounded,
                        label: AppStrings.profile,
                        active: current == MainNavItem.profile,
                        onTap: () => onTap(MainNavItem.profile),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppStyle.bodySmall.copyWith(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTab extends StatelessWidget {
  const _ScanTab({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = active ? AppColors.primary : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.center_focus_weak_rounded,
                  color: AppColors.onPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                AppStrings.scan,
                style: AppStyle.bodySmall.copyWith(
                  color: labelColor,
                  fontSize: 10.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
