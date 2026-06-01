import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/style.dart';
import 'app_brand_title.dart';

/// Shared STYLEAI header for main tab screens — fixed padding and height.
class AppBrandHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBrandHeaderBar({super.key, this.trailing});

  final Widget? trailing;

  static double get topPadding => 8.h;
  static double get bottomPadding => 16.h;
  static double get contentHeight => 32.h;

  static EdgeInsets get padding => EdgeInsets.fromLTRB(
        AppStyle.horizontalPadding,
        topPadding,
        AppStyle.horizontalPadding,
        bottomPadding,
      );

  static double get totalHeight => topPadding + contentHeight + bottomPadding;

  @override
  Size get preferredSize => Size.fromHeight(totalHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: contentHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(child: AppBrandTitle()),
            if (trailing != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
