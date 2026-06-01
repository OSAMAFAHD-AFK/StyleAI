import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/style.dart';
import 'glass_container.dart';

class DropdownOption<T> {
  const DropdownOption({required this.value, required this.label, this.leading});

  final T value;
  final String label;
  final Widget? leading;
}

class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<DropdownOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = options.any((o) => o.value == value)
        ? value
        : options.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.fieldLabel),
        SizedBox(height: 8.h),
        GlassContainer(
          borderRadius: BorderRadius.circular(AppStyle.fieldRadius),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          opacity: 0.06,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: safeValue,
              dropdownColor: AppColors.surfaceElevated,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
                size: 24.sp,
              ),
              items: options
                  .map(
                    (o) => DropdownMenuItem<T>(
                      value: o.value,
                      child: Row(
                        children: [
                          if (o.leading != null) ...[
                            o.leading!,
                            SizedBox(width: 10.w),
                          ],
                          Expanded(
                            child: Text(
                              o.label,
                              style: AppStyle.bodyLarge.copyWith(fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
