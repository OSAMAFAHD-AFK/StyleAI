import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

class GenderAvatarBadge extends StatelessWidget {
  const GenderAvatarBadge({
    super.key,
    required this.gender,
    this.size,
  });

  final String gender;
  final double? size;

  bool get _isMale => gender == 'male';

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? 40.w;
    final iconSize = diameter * 0.5;
    final accent = _isMale ? const Color(0xFF1976D2) : const Color(0xFFE91E8C);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.22),
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.4),
      ),
      child: Icon(
        _isMale ? Icons.man_outlined : Icons.woman_outlined,
        color: AppColors.textMuted,
        size: iconSize,
      ),
    );
  }
}
