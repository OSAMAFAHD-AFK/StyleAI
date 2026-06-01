import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/models/affiliate_product_offer.dart';
import '../../../../../core/models/ranked_offers_result.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/app_brand_header_bar.dart';
import '../../../../../core/widgets/glass_bottom_nav_bar.dart';
import '../../../../../core/widgets/product_offer_card.dart';
import '../../manager/search_flow_cubit.dart';
import '../../../data/data_sources/search_mock_data_source.dart';
import '../../utils/search_navigation.dart';

class SearchResultsViewBody extends StatefulWidget {
  const SearchResultsViewBody({super.key, required this.requestId});

  final String requestId;

  @override
  State<SearchResultsViewBody> createState() => _SearchResultsViewBodyState();
}

class _SearchResultsViewBodyState extends State<SearchResultsViewBody> {
  final Set<String> _savedOfferIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchFlowCubit, SearchFlowState>(
      builder: (context, state) {
        final ranked = _effectiveResults(widget.requestId, state);
        final dupes = ranked.dupes;
        final originals = ranked.originals;
        final total = ranked.summary?.totalOffers ?? (originals.length + dupes.length);

        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                AppBrandHeaderBar(
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: AppStrings.deletePhoto,
                    onPressed: () => SearchNavigation.startNewSearch(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
                  child: _ResultsHeader(
                    total: total,
                    imagePath: state.localImagePath,
                    firstOfferImage: originals.isNotEmpty
                        ? originals.first.imageUrl
                        : dupes.isNotEmpty
                            ? dupes.first.imageUrl
                            : null,
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
                  child: Text(
                    AppStrings.exactMatch,
                    style: AppStyle.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 8.h),
                _OfferCarousel(
                  offers: originals,
                  savedOfferIds: _savedOfferIds,
                  onToggleSaved: _toggleSaved,
                  onAction: (_) => _showSnack(AppStrings.purchaseLinkComingSoon),
                  emptyPlaceholder: _emptySection(),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 16.sp),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          AppStrings.smartAlternatives,
                          style: AppStyle.titleMedium.copyWith(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                _OfferCarousel(
                  offers: dupes,
                  savedOfferIds: _savedOfferIds,
                  onToggleSaved: _toggleSaved,
                  onAction: (_) => _showSnack(AppStrings.purchaseLinkComingSoon),
                  emptyPlaceholder: _emptySection(),
                ),
                SizedBox(height: GlassBottomNavBar.contentBottomInset(context)),
              ],
            ),
        );
      },
    );
  }

  void _toggleSaved(AffiliateProductOffer offer) {
    setState(() {
      if (_savedOfferIds.contains(offer.offerId)) {
        _savedOfferIds.remove(offer.offerId);
        _showSnack(AppStrings.removedFromSaved);
      } else {
        _savedOfferIds.add(offer.offerId);
        _showSnack(AppStrings.addedToSaved);
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
  }

  RankedOffersResult _effectiveResults(String requestId, SearchFlowState state) {
    final ranked = state.rankedResult;
    if (ranked != null &&
        (ranked.originals.isNotEmpty || ranked.dupes.isNotEmpty)) {
      return ranked;
    }
    if (state.streamedOffers.isNotEmpty) {
      return RankedOffersResult(
        requestId: requestId,
        originals: const [],
        dupes: state.streamedOffers,
        status: 'streaming',
      );
    }
    return SearchMockDataSource.buildResults(requestId);
  }

  Widget _emptySection() {
    return Container(
      height: 100.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text('Results streaming in...', style: AppStyle.bodyMedium),
    );
  }
}

class _OfferCarousel extends StatelessWidget {
  const _OfferCarousel({
    required this.offers,
    required this.savedOfferIds,
    required this.onToggleSaved,
    required this.onAction,
    required this.emptyPlaceholder,
  });

  static const _cardWidth = 158.0;
  static const _carouselHeight = 228.0;

  final List<AffiliateProductOffer> offers;
  final Set<String> savedOfferIds;
  final void Function(AffiliateProductOffer offer) onToggleSaved;
  final void Function(AffiliateProductOffer offer) onAction;
  final Widget emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
        child: emptyPlaceholder,
      );
    }

    return SizedBox(
      height: _carouselHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
        itemCount: offers.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final offer = offers[i];
          return SizedBox(
            width: _cardWidth.w,
            child: ProductOfferCard(
              offer: offer,
              variant: OfferCardVariant.exactMatch,
              compact: true,
              isSaved: savedOfferIds.contains(offer.offerId),
              onFavoriteTap: () => onToggleSaved(offer),
              onActionTap: () => onAction(offer),
            ),
          );
        },
      ),
    );
  }
}

class _ResultsHeader extends StatefulWidget {
  const _ResultsHeader({
    required this.total,
    this.imagePath,
    this.firstOfferImage,
  });

  final int total;
  final String? imagePath;
  final String? firstOfferImage;

  @override
  State<_ResultsHeader> createState() => _ResultsHeaderState();
}

class _ResultsHeaderState extends State<_ResultsHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: _glowAnimation.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.45),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: child,
                ),
              ),
            );
          },
          child: _buildThumbnail(),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      AppStrings.analysisComplete,
                      style: AppStyle.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${widget.total} ${AppStrings.matchesFound}',
                style: AppStyle.headlineMedium.copyWith(fontSize: 20.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    if (widget.imagePath != null && File(widget.imagePath!).existsSync()) {
      return Image.file(File(widget.imagePath!), fit: BoxFit.cover);
    }

    if (widget.firstOfferImage != null && widget.firstOfferImage!.isNotEmpty) {
      return Image.network(widget.firstOfferImage!, fit: BoxFit.cover);
    }

    return Container(
      color: AppColors.surfaceElevated,
      child: Icon(Icons.checkroom_outlined, color: AppColors.textMuted, size: 28.sp),
    );
  }
}
