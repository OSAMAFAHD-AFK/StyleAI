import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../../core/utils/style.dart';
import '../../data/models/capture_source.dart';
import '../manager/search_flow_cubit.dart';

abstract final class SearchNavigation {
  static void openSearchTab(BuildContext context) {
    final cubit = sl<SearchFlowCubit>();
    final state = cubit.state;

    if (state.hasCompletedResults) {
      context.go(AppRoutes.searchResultsFor(state.requestId!));
      return;
    }

    context.go(AppRoutes.searchTab);
  }

  /// Opens a past search from home or collections history (mock until backend).
  static void openHistoryResults(BuildContext context, String requestId) {
    final cubit = sl<SearchFlowCubit>();
    if (cubit.state.requestId != requestId || cubit.state.rankedResult == null) {
      cubit.loadResults(requestId);
    }
    context.go(AppRoutes.searchResultsFor(requestId));
  }

  static Future<void> startNewSearch(BuildContext context) async {
    final confirmed = await confirmNewSearch(context);
    if (!context.mounted || !confirmed) return;

    context.read<SearchFlowCubit>().clearSession();
    context.go(AppRoutes.searchTab);
  }

  /// Opens the system gallery picker and continues to search when an image is chosen.
  static Future<void> pickFromGallery(BuildContext context) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!context.mounted || file == null) return;

    context.go(
      AppRoutes.searchTab,
      extra: {
        'imagePath': file.path,
        'source': CaptureSource.gallery.name,
      },
    );
  }
}

Future<bool> confirmNewSearch(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(AppStrings.newSearchTitle, style: AppStyle.titleMedium),
      content: Text(
        AppStrings.newSearchMessage,
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
            AppStrings.newSearch,
            style: AppStyle.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}
