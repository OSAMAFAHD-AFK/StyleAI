import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/app_brand_header_bar.dart';
import '../../../../../core/widgets/glass_bottom_nav_bar.dart';
import '../../../../../core/widgets/product_offer_card.dart';
import '../../../../Feature_4_visual_search/presentation/utils/search_navigation.dart';
import '../../manager/collections_cubit.dart';
import 'search_history_card.dart';
import 'segment_tab_switcher.dart';

class CollectionsViewBody extends StatelessWidget {
  const CollectionsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppBrandHeaderBar(),
              SegmentTabSwitcher(
                labels: const [AppStrings.searchResultsTab, AppStrings.savedTab],
                selectedIndex: state.selectedTabIndex,
                onChanged: context.read<CollectionsCubit>().selectTab,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: state.selectedTabIndex == 0
                    ? _searchHistoryList(context, state)
                    : _savedGrid(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _savedGrid(BuildContext context, CollectionsState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.curatedCollection, style: AppStyle.headlineMedium),
          SizedBox(height: 6.h),
          Text(
            '${state.savedOffers.length} ${AppStrings.savedPiecesCount}',
            style: AppStyle.bodyMedium,
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: state.savedOffers.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.savedTab,
                      style: AppStyle.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.only(
                      bottom: GlassBottomNavBar.contentBottomInset(context),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      mainAxisExtent: 228.h,
                    ),
                    itemCount: state.savedOffers.length,
                    itemBuilder: (_, i) {
                      final offer = state.savedOffers[i];
                      return ProductOfferCard(
                        offer: offer,
                        variant: OfferCardVariant.exactMatch,
                        compact: true,
                        isSaved: true,
                        onFavoriteTap: () {
                          context.read<CollectionsCubit>().removeSavedOffer(offer.offerId);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.removedFromSaved),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.surfaceElevated,
                              ),
                            );
                        },
                        onActionTap: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.purchaseLinkComingSoon),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.surfaceElevated,
                              ),
                            );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _searchHistoryList(BuildContext context, CollectionsState state) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppStyle.horizontalPadding,
        0,
        AppStyle.horizontalPadding,
        GlassBottomNavBar.contentBottomInset(context),
      ),
      itemCount: state.searchHistory.length,
      itemBuilder: (context, i) {
        final item = state.searchHistory[i];
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: SearchHistoryCard(
            item: item,
            onTap: () => SearchNavigation.openHistoryResults(context, item.requestId),
          ),
        );
      },
    );
  }
}
