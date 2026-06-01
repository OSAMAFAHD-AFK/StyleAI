import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../Feature_4_visual_search/presentation/utils/search_navigation.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_router.dart';
import 'home_action_card.dart';

/// Shared float animation — only the card shell moves; inner content stays crisp.
class HomeActionCardsRow extends StatefulWidget {
  const HomeActionCardsRow({super.key});

  @override
  State<HomeActionCardsRow> createState() => _HomeActionCardsRowState();
}

class _HomeActionCardsRowState extends State<HomeActionCardsRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Widget _floatingCard({required Widget child, required double offset}) {
    return Transform.translate(
      offset: Offset(0, offset),
      filterQuality: FilterQuality.high,
      child: RepaintBoundary(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, _) {
        final offset = _floatAnimation.value.h;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _floatingCard(
                offset: offset,
                child: HomeActionCard(
                  icon: Icons.camera_alt_outlined,
                  label: AppStrings.captureLivePhoto,
                  variant: HomeActionCardVariant.camera,
                  onTap: () => context.push(AppRoutes.scanner),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: _floatingCard(
                offset: offset,
                child: HomeActionCard(
                  icon: Icons.photo_library_outlined,
                  label: AppStrings.uploadScreenshot,
                  variant: HomeActionCardVariant.gallery,
                  onTap: () => SearchNavigation.pickFromGallery(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
