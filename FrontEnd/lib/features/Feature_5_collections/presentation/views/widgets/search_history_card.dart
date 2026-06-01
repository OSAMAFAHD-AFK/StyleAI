import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../../../core/widgets/mock_network_image.dart';
import '../../../data/models/search_history_item_model.dart';

class SearchHistoryCard extends StatelessWidget {
  const SearchHistoryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final SearchHistoryItemModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: AppColors.primary.withValues(alpha: 0.08),
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(AppStyle.cardRadius),
          padding: EdgeInsets.all(12.w),
          opacity: 0.05,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  width: 72.w,
                  height: 88.h,
                  child: MockNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.timestampLabel, style: AppStyle.bodySmall),
                    SizedBox(height: 4.h),
                    Text(item.title, style: AppStyle.titleMedium.copyWith(fontSize: 15.sp)),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        item.searchType,
                        style: AppStyle.bodySmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(item.resultSummary, style: AppStyle.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
