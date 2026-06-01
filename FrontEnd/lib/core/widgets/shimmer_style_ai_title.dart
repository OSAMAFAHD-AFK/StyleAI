import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/style.dart';

/// Uppercase STYLEAI — white glow with a diagonal green shimmer sweep.
class ShimmerStyleAiTitle extends StatefulWidget {
  const ShimmerStyleAiTitle({
    super.key,
    this.showTagline = true,
    this.fontSize,
  });

  final bool showTagline;
  final double? fontSize;

  @override
  State<ShimmerStyleAiTitle> createState() => _ShimmerStyleAiTitleState();
}

class _ShimmerStyleAiTitleState extends State<ShimmerStyleAiTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _slantY = 0.72;
  static const _bandWidth = 1.22;
  static const _fadeWidth = 0.44;

  static Color _blend(double amount) =>
      Color.lerp(AppColors.white, AppColors.primary, amount)!;

  static List<Color> get _gradientColors => [
        AppColors.white,
        AppColors.white,
        _blend(0.05),
        _blend(0.14),
        _blend(0.28),
        _blend(0.44),
        _blend(0.60),
        _blend(0.76),
        AppColors.primary,
        AppColors.primary,
        AppColors.primary,
        _blend(0.76),
        _blend(0.60),
        _blend(0.44),
        _blend(0.28),
        _blend(0.14),
        _blend(0.05),
        AppColors.white,
        AppColors.white,
      ];

  static List<double> _buildStops(double t) {
    final half = _bandWidth / 2;
    var prev = -1.0;

    double next(double value) {
      final clamped = value.clamp(0.0, 1.0);
      final stop = clamped <= prev ? prev + 0.0005 : clamped;
      prev = stop;
      return stop;
    }

    final left = t - half;
    final right = t + half;
    final f = _fadeWidth;

    return [
      next(0.0),
      next(left - f),
      next(left - f * 0.86),
      next(left - f * 0.68),
      next(left - f * 0.50),
      next(left - f * 0.34),
      next(left - f * 0.20),
      next(left - f * 0.08),
      next(left),
      next(t),
      next(right),
      next(right + f * 0.08),
      next(right + f * 0.20),
      next(right + f * 0.34),
      next(right + f * 0.50),
      next(right + f * 0.68),
      next(right + f * 0.86),
      next(right + f),
      next(1.0),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.fontSize ?? 40.sp;
    final letterSpacing = size * 0.28;
    final titleStyle = GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: letterSpacing,
      height: 1.05,
      color: AppColors.white,
    );
    final label = AppStrings.appName.toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                label,
                style: titleStyle.copyWith(
                  color: AppColors.white.withValues(alpha: 0.45),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final travel = t * 2.4 - 1.2;

                return ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(travel - 0.55, -_slantY),
                      end: Alignment(travel + 0.55, _slantY),
                      colors: _gradientColors,
                      stops: _buildStops(t),
                    ).createShader(bounds);
                  },
                  child: Text(
                    label,
                    style: titleStyle.copyWith(
                      shadows: [
                        Shadow(
                          color: AppColors.white.withValues(alpha: 0.35),
                          blurRadius: 18,
                        ),
                        Shadow(
                          color: AppColors.white.withValues(alpha: 0.18),
                          blurRadius: 36,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
        if (widget.showTagline) ...[
          SizedBox(height: 10.h),
          Text(
            AppStrings.tagline,
            style: AppStyle.labelCaps,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
