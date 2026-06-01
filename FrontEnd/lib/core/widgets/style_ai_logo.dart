import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'shimmer_style_ai_title.dart';

enum LogoSize { large, small }

/// @deprecated Use [AppBrandTitle] or [ShimmerStyleAiTitle] instead.
class StyleAiLogo extends StatelessWidget {
  const StyleAiLogo({
    super.key,
    this.showTagline = false,
    this.size = LogoSize.large,
  });

  final bool showTagline;
  final LogoSize size;

  @override
  Widget build(BuildContext context) {
    return ShimmerStyleAiTitle(
      showTagline: showTagline,
      fontSize: size == LogoSize.large ? 36.sp : 22.sp,
    );
  }
}
