import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';

class ScannerViewBody extends StatefulWidget {
  const ScannerViewBody({
    super.key,
    required this.onCapture,
    required this.onGallery,
    required this.onClose,
  });

  final void Function(String path) onCapture;
  final VoidCallback onGallery;
  final VoidCallback onClose;

  @override
  State<ScannerViewBody> createState() => _ScannerViewBodyState();
}

class _ScannerViewBodyState extends State<ScannerViewBody> {
  CameraController? _controller;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (mounted) setState(() => _controller = controller);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final file = await _controller!.takePicture();
      widget.onCapture(file.path);
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) widget.onCapture(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller?.value.isInitialized == true)
            CameraPreview(_controller!)
          else
            Container(color: AppColors.surface),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          _ViewfinderOverlay(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ),
                const Spacer(),
                Text(AppStrings.placeItemCenter, style: AppStyle.bodyMedium),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleControl(
                        icon: Icons.tune,
                        onTap: () {},
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 76.w,
                          height: 76.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGlow,
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Icon(Icons.camera_alt, color: AppColors.onPrimary, size: 32.sp),
                        ),
                      ),
                      _CircleControl(
                        icon: Icons.photo_library_outlined,
                        onTap: widget.onGallery,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260.w,
        height: 320.h,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const len = 28.0;
    final w = size.width;
    final h = size.height;

    void corner(Offset start, Offset hEnd, Offset vEnd) {
      canvas.drawLine(start, hEnd, paint);
      canvas.drawLine(start, vEnd, paint);
    }

    corner(Offset.zero, const Offset(len, 0), const Offset(0, len));
    corner(Offset(w, 0), Offset(w - len, 0), Offset(w, len));
    corner(Offset(0, h), Offset(len, h), Offset(0, h - len));
    corner(Offset(w, h), Offset(w - len, h), Offset(w, h - len));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, color: AppColors.white, size: 22.sp),
      ),
    );
  }
}
