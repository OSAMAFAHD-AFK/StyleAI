import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/style.dart';
import 'glass_container.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.hasError = false,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.fieldLabel),
        SizedBox(height: 8.h),
        GlassContainer(
          borderRadius: BorderRadius.circular(AppStyle.fieldRadius),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          opacity: 0.06,
          borderColor: hasError ? AppColors.error : null,
          borderWidth: hasError ? 1.5 : 1,
          child: TextField(
            controller: controller,
            style: AppStyle.bodyLarge.copyWith(fontSize: 15.sp),
            cursorColor: AppColors.primary,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppStyle.bodyLarge.copyWith(
                fontSize: 15.sp,
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyle.fieldHintRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              errorText!,
              style: AppStyle.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
