import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/app_brand_header_bar.dart';
import '../../../../../core/widgets/gender_avatar_badge.dart';
import '../../../../../core/widgets/glass_bottom_nav_bar.dart';
import '../../../../../core/widgets/radial_glow_background.dart';
import '../../../../../core/widgets/thrift_counter_badge.dart';
import '../../../../Feature_4_visual_search/presentation/utils/search_navigation.dart';
import '../../../../Feature_5_collections/presentation/utils/collections_navigation.dart';
import '../../manager/home_cubit.dart';
import 'home_action_cards_row.dart';
import '../../../../Feature_5_collections/presentation/views/widgets/search_history_card.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return RadialGlowBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppBrandHeaderBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppStyle.horizontalPadding,
                      0,
                      AppStyle.horizontalPadding,
                      GlassBottomNavBar.contentBottomInset(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GenderAvatarBadge(gender: state.gender),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                state.displayName,
                                style: AppStyle.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            ThriftCounterBadge(
                              compact: true,
                              amount: state.thrift?.totalSavings ?? 430,
                              currency: state.thrift?.currency ?? 'USD',
                            ),
                          ],
                        ),
                  SizedBox(height: 28.h),
                  Center(
                    child: Text(
                      AppStrings.tagline,
                      style: AppStyle.headlineMedium.copyWith(
                        color: AppColors.primary,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  const HomeActionCardsRow(),
                  if (state.recentSearchResults.isNotEmpty) ...[
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.recentSearchResults, style: AppStyle.titleMedium),
                        GestureDetector(
                          onTap: () => CollectionsNavigation.openSearchResults(context),
                          child: Text(
                            AppStrings.viewAll,
                            style: AppStyle.bodySmall.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ...state.recentSearchResults.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: SearchHistoryCard(
                          item: item,
                          onTap: () => SearchNavigation.openHistoryResults(
                            context,
                            item.requestId,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
