import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'shimmer_style_ai_title.dart';

/// Compact STYLEAI wordmark for tab screens and app bars.
class AppBrandTitle extends StatelessWidget {
  const AppBrandTitle({super.key});

  static double get tabFontSize => 22.sp;

  @override
  Widget build(BuildContext context) {
    return ShimmerStyleAiTitle(
      showTagline: false,
      fontSize: tabFontSize,
    );
  }
}
