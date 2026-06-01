import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../presentation/utils/search_navigation.dart';
import '../../data/models/capture_source.dart';
import 'widgets/scanner_view_body.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerViewBody(
      onCapture: (path) {
        context.pop();
        context.go(
          AppRoutes.searchTab,
          extra: {
            'imagePath': path,
            'source': CaptureSource.camera.name,
          },
        );
      },
      onGallery: () {
        context.pop();
        SearchNavigation.pickFromGallery(context);
      },
      onClose: () => context.pop(),
    );
  }
}
