import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';

enum HomeActionCardVariant { camera, gallery }

class HomeActionCard extends StatefulWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.variant,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final HomeActionCardVariant variant;

  @override
  State<HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<HomeActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppStyle.cardRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 12.w),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (widget.variant == HomeActionCardVariant.gallery)
                Positioned.fill(
                  child: _GalleryScanLineOverlay(controller: _scanController),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepaintBoundary(
                    child: SizedBox(
                      width: 72.w,
                      height: 72.w,
                      child: widget.variant == HomeActionCardVariant.camera
                          ? _CameraIconFrame(icon: widget.icon)
                          : Icon(
                              widget.icon,
                              size: 36.sp,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: AppStyle.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryScanLineOverlay extends StatelessWidget {
  const _GalleryScanLineOverlay({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final travel = constraints.maxHeight + 8.h;
            final top = controller.value * travel - 4.h;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: top,
                  child: IgnorePointer(
                    child: Container(
                      height: 2.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0),
                            AppColors.primary.withValues(alpha: 0.85),
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                            AppColors.primary.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.25, 0.5, 0.75, 1],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CameraIconFrame extends StatelessWidget {
  const _CameraIconFrame({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bracketSize = 14.w;
    const stroke = 2.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, size: 36.sp, color: AppColors.primary),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Stack(
              children: [
                _CornerBracket(
                  alignment: Alignment.topLeft,
                  size: bracketSize,
                  stroke: stroke,
                ),
                _CornerBracket(
                  alignment: Alignment.topRight,
                  size: bracketSize,
                  stroke: stroke,
                  flipX: true,
                ),
                _CornerBracket(
                  alignment: Alignment.bottomLeft,
                  size: bracketSize,
                  stroke: stroke,
                  flipY: true,
                ),
                _CornerBracket(
                  alignment: Alignment.bottomRight,
                  size: bracketSize,
                  stroke: stroke,
                  flipX: true,
                  flipY: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.alignment,
    required this.size,
    required this.stroke,
    this.flipX = false,
    this.flipY = false,
  });

  final Alignment alignment;
  final double size;
  final double stroke;
  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.flip(
        flipX: flipX,
        flipY: flipY,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CornerBracketPainter(stroke: stroke),
          ),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  _CornerBracketPainter({required this.stroke});

  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
