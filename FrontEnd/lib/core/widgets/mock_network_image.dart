import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

class MockNetworkImage extends StatelessWidget {
  const MockNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.aspectRatio,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );

    Widget child = image;
    if (aspectRatio != null) {
      child = AspectRatio(aspectRatio: aspectRatio!, child: image);
    }
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(Icons.checkroom_outlined, color: AppColors.textMuted, size: 32.sp),
      ),
    );
  }
}
