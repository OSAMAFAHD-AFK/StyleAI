import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/app_brand_header_bar.dart';
import '../../../../../core/widgets/glass_bottom_nav_bar.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/radial_glow_background.dart';
import '../../utils/search_navigation.dart';
import '../../../data/models/capture_source.dart';

class SearchEmptyViewBody extends StatelessWidget {
  const SearchEmptyViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialGlowBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBrandHeaderBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48.h),
                    Center(
                      child: Icon(
                        Icons.checkroom_outlined,
                        size: 72.sp,
                        color: AppColors.primary.withValues(alpha: 0.85),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppStrings.searchEmptyTitle,
                      style: AppStyle.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppStrings.searchEmptySubtitle,
                      style: AppStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    PrimaryButton(
                      label: AppStrings.openCamera,
                      icon: Icon(Icons.camera_alt_outlined, color: AppColors.onPrimary, size: 22.sp),
                      onPressed: () => context.push(AppRoutes.scanner),
                    ),
                    SizedBox(height: 14.h),
                    _SecondaryActionButton(
                      label: AppStrings.chooseFromGallery,
                      icon: Icons.photo_library_outlined,
                      onTap: () => SearchNavigation.pickFromGallery(context),
                    ),
                    SizedBox(height: GlassBottomNavBar.contentBottomInset(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(AppStyle.buttonRadius),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        opacity: 0.06,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppStyle.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> confirmDeleteCapture(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(AppStrings.deletePhotoTitle, style: AppStyle.titleMedium),
      content: Text(
        AppStrings.deletePhotoMessage,
        style: AppStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            AppStrings.cancel,
            style: AppStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            AppStrings.remove,
            style: AppStyle.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}

void openReplaceCaptureSource(BuildContext context, CaptureSource? source) {
  switch (source) {
    case CaptureSource.camera:
      context.push(AppRoutes.scanner);
    case CaptureSource.gallery:
    case null:
      SearchNavigation.pickFromGallery(context);
  }
}
