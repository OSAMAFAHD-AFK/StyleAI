import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/style.dart';
import 'glass_container.dart';

class ThriftCounterBadge extends StatefulWidget {
  const ThriftCounterBadge({
    super.key,
    required this.amount,
    required this.currency,
    this.compact = false,
  });

  final double amount;
  final String currency;
  final bool compact;

  @override
  State<ThriftCounterBadge> createState() => _ThriftCounterBadgeState();
}

class _ThriftCounterBadgeState extends State<ThriftCounterBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.compactCurrency(symbol: '\$').format(
      widget.amount,
    );
    final radius = widget.compact ? 22.r : 24.r;
    final iconSize = widget.compact ? 17.sp : 18.sp;
    final labelStyle = AppStyle.bodySmall.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: widget.compact ? 12.sp : null,
      height: 1.1,
    );

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bandWidth = constraints.maxWidth * 0.55;
                    final left = (_shimmerController.value * (constraints.maxWidth + bandWidth)) - bandWidth;

                    return Stack(
                      children: [
                        Positioned(
                          left: left,
                          top: 0,
                          bottom: 0,
                          width: bandWidth,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0),
                                    AppColors.primary.withValues(alpha: 0.12),
                                    AppColors.primary.withValues(alpha: 0.35),
                                    AppColors.primary.withValues(alpha: 0.12),
                                    AppColors.primary.withValues(alpha: 0),
                                  ],
                                  stops: const [0, 0.2, 0.5, 0.8, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      child: GlassContainer(
        borderRadius: BorderRadius.circular(radius),
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 12.w : 14.w,
          vertical: widget.compact ? 9.h : 8.h,
        ),
        opacity: 0.08,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              color: AppColors.primary,
              size: iconSize,
            ),
            SizedBox(width: widget.compact ? 5.w : 6.w),
            Text(
              '${AppStrings.savedThisMonth}: $formatted',
              style: labelStyle,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
