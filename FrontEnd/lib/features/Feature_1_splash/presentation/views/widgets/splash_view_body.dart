import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/widgets/glass_primary_button.dart';
import '../../manager/auth_cubit.dart';
import 'google_logo_icon.dart';
import '../../../../../core/widgets/shimmer_style_ai_title.dart';

class SplashViewBody extends StatelessWidget {
  const SplashViewBody({super.key});

  static const _backgroundAsset = 'assets/images/splash_background.png';
  static const _backgroundUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDvKJRIgZoMul6Fbh5sE-psbjvpwaWgZns9E-vJPeUkCWsSd3XyDF4mqA7_MmXhxcGFeuTJXeOmNEzrIAI48zzBWMwxgZgG06e3HYl-YbwE4iRM_NYYIw7c5wXdE6zcKlf2xJQJQE3SUpQ93PUXpHvRcbZwhOqLsPmXoWdsUfwcFofotQb6mSvISOTs3BEbCpi3puZDLvk8wvEyr3IW_IsUUeLmVp_Yk_3i1Qutshrmhcb1iR4Fht40kEJpIkH3xv1m7IaGoqKF9wE';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppRoutes.profileSetup);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.38, 0, 0, 0, 0,
              0, 0.38, 0, 0, 0,
              0, 0, 0.38, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: CachedNetworkImage(
              imageUrl: _backgroundUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              placeholder: (_, __) => Image.asset(
                _backgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              errorWidget: (_, __, ___) => Image.asset(
                _backgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Color(0xFF000000)),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.12),
                radius: 0.72,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.38),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 4),
                const Center(child: ShimmerStyleAiTitle()),
                const Spacer(flex: 3),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return GlassPrimaryButton(
                        label: loading ? 'Signing in...' : AppStrings.loginWithGoogle,
                        onPressed: loading
                            ? null
                            : () => context.read<AuthCubit>().signInWithGoogle(),
                        leading: loading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : GoogleLogoIcon(size: 22.w),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
