import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../manager/search_flow_cubit.dart';
import 'search_empty_view_body.dart';

class CaptureAnalysisViewBody extends StatelessWidget {
  const CaptureAnalysisViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchFlowCubit, SearchFlowState>(
      builder: (context, state) {
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
                        SizedBox(height: 24.h),
                        GlassContainer(
                    borderRadius: BorderRadius.circular(AppStyle.cardRadius),
                    padding: EdgeInsets.all(16.w),
                    opacity: 0.06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.capturedClothing,
                              style: AppStyle.titleMedium,
                            ),
                            Row(
                              children: [
                                _CaptureActionIconButton(
                                  icon: Icons.edit_outlined,
                                  tooltip: AppStrings.replacePhoto,
                                  onTap: () => openReplaceCaptureSource(
                                    context,
                                    state.captureSource,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                _CaptureActionIconButton(
                                  icon: Icons.delete_outline_rounded,
                                  tooltip: AppStrings.deletePhoto,
                                  onTap: () async {
                                    final confirmed =
                                        await confirmDeleteCapture(context);
                                    if (!context.mounted || !confirmed) return;
                                    context.read<SearchFlowCubit>().clearSession();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Image.file(
                              File(state.localImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _analysisLabel(state),
                                style: AppStyle.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  PrimaryButton(
                    label: AppStrings.searchNow,
                    isLoading: state.status == SearchFlowStatus.uploading,
                    icon: Icon(
                      Icons.search,
                      color: AppColors.onPrimary,
                      size: 22.sp,
                    ),
                    onPressed: state.canSearch
                        ? () {
                            final cubit = context.read<SearchFlowCubit>();
                            final requestId = cubit.ensureRequestId();
                            context.push('${AppRoutes.processing}/$requestId');
                          }
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  Text(AppStrings.searchNowDescription, style: AppStyle.bodyMedium),
                  SizedBox(height: GlassBottomNavBar.contentBottomInset(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _analysisLabel(SearchFlowState state) {
    if (state.status == SearchFlowStatus.uploading) {
      return AppStrings.analyzingOutfit;
    }

    final tags = state.searchResult?.tags;
    if (tags != null) {
      return '${tags.category} · ${tags.color}';
    }

    return AppStrings.aiEngineReady;
  }
}

class _CaptureActionIconButton extends StatelessWidget {
  const _CaptureActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
