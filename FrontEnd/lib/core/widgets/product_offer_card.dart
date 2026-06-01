import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/affiliate_product_offer.dart';
import '../utils/app_colors.dart';
import '../utils/style.dart';

enum OfferCardVariant { exactMatch, alternative }

class ProductOfferCard extends StatelessWidget {
  const ProductOfferCard({
    super.key,
    required this.offer,
    required this.variant,
    this.compact = false,
    this.isSaved = false,
    this.onFavoriteTap,
    this.onActionTap,
  });

  final AffiliateProductOffer offer;
  final OfferCardVariant variant;
  final bool compact;
  final bool isSaved;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final savings = offer.savingsPercent?.round() ?? 0;
    final originalPrice = _originalPrice(offer);
    final priceFormat = NumberFormat('#,###', 'en_US');
    final imageHeight = compact
        ? 112.h
        : variant == OfferCardVariant.exactMatch
            ? 170.h
            : 220.h;
    final cardRadius = compact ? 12.r : 16.r;
    final contentPadding = compact ? 8.w : 12.w;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProductImageCarousel(
                  imageUrls: offer.galleryImages,
                  compact: compact,
                ),
                if (savings > 0)
                  Positioned(
                    top: compact ? 6.h : 10.h,
                    left: compact ? 6.w : 10.w,
                    child: _SaveBadge(savings: savings, compact: compact),
                  ),
                Positioned(
                  top: compact ? 6.h : 8.h,
                  right: compact ? 6.w : 8.w,
                  child: _FavoriteButton(
                    isSaved: isSaved,
                    onTap: onFavoriteTap,
                    compact: compact,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  offer.merchantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: compact ? 10.sp : null,
                  ),
                ),
                SizedBox(height: compact ? 3.h : 6.h),
                Text(
                  '${priceFormat.format(offer.localizedPrice.round())} ${offer.localizedCurrency}',
                  style: AppStyle.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: compact ? 14.sp : 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (originalPrice != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    '${priceFormat.format(originalPrice.round())} ${offer.localizedCurrency}',
                    style: AppStyle.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: compact ? 9.sp : null,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                ],
                SizedBox(height: compact ? 8.h : 12.h),
                SizedBox(
                  width: double.infinity,
                  height: compact ? 32.h : 42.h,
                  child: ElevatedButton(
                    onPressed: onActionTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(compact ? 8.r : 12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            variant == OfferCardVariant.exactMatch
                                ? AppStrings.startSaving
                                : AppStrings.getAlternative,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.button.copyWith(
                              fontSize: compact ? 11.sp : 14.sp,
                            ),
                          ),
                        ),
                        if (variant == OfferCardVariant.alternative) ...[
                          SizedBox(width: 4.w),
                          Icon(Icons.open_in_new, size: compact ? 12.sp : 16.sp),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double? _originalPrice(AffiliateProductOffer offer) {
    final saved = offer.savedAmount;
    if (saved != null && saved > 0) {
      return offer.localizedPrice + saved;
    }
    final pct = offer.savingsPercent;
    if (pct != null && pct > 0 && pct < 100) {
      return offer.localizedPrice / (1 - pct / 100);
    }
    return null;
  }
}

class _ProductImageCarousel extends StatefulWidget {
  const _ProductImageCarousel({
    required this.imageUrls,
    required this.compact,
  });

  final List<String> imageUrls;
  final bool compact;

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late final PageController _pageController;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls;

    if (images.isEmpty) {
      return const _ProductImagePlaceholder(compact: false);
    }

    if (images.length == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _ProductImage(imageUrl: images.first, compact: widget.compact),
          Positioned(
            left: 0,
            right: 0,
            bottom: widget.compact ? 6.h : 10.h,
            child: _PageDots(count: 1, activeIndex: 0, compact: widget.compact),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _activeIndex = index),
          itemBuilder: (_, index) {
            return _ProductImage(
              imageUrl: images[index],
              compact: widget.compact,
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.compact ? 6.h : 10.h,
          child: _PageDots(
            count: images.length,
            activeIndex: _activeIndex,
            compact: widget.compact,
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.compact});

  final String imageUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => _ProductImagePlaceholder(compact: compact),
      errorWidget: (_, __, ___) => _ProductImagePlaceholder(compact: compact),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      alignment: Alignment.center,
      child: Icon(
        Icons.checkroom_outlined,
        color: AppColors.textMuted,
        size: compact ? 32.sp : 48.sp,
      ),
    );
  }
}

class _SaveBadge extends StatelessWidget {
  const _SaveBadge({required this.savings, this.compact = false});

  final int savings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 8.w,
        vertical: compact ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(compact ? 6.r : 8.r),
      ),
      child: Text(
        'Save $savings%',
        style: AppStyle.bodySmall.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 9.sp : 11.sp,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isSaved,
    this.onTap,
    this.compact = false,
  });

  final bool isSaved;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(compact ? 5.w : 8.w),
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: isSaved ? AppColors.primary : AppColors.white,
            size: compact ? 14.sp : 18.sp,
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.activeIndex,
    required this.compact,
  });

  final int count;
  final int activeIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6.w : 8.w,
          vertical: compact ? 3.h : 4.h,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final active = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? (compact ? 7.w : 8.w) : (compact ? 5.w : 6.w),
              height: active ? (compact ? 7.w : 8.w) : (compact ? 5.w : 6.w),
              margin: EdgeInsets.symmetric(horizontal: compact ? 2.w : 3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppColors.primary
                    : AppColors.white.withValues(alpha: 0.45),
              ),
            );
          }),
        ),
      ),
    );
  }
}
