import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';

class GenderSelectionCard extends StatelessWidget {
  const GenderSelectionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyle.fieldRadius),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.card.withValues(alpha: 0.65),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.surfaceElevated,
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.55)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                icon,
                size: 28.sp,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            )
                .animate(target: selected ? 1 : 0)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.05, 1.05),
                  duration: 280.ms,
                  curve: Curves.easeOutBack,
                ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: AppStyle.bodyMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: selected ? 24.w : 0,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
