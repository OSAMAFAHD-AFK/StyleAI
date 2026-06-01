import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/style.dart';
import '../../../data/data_sources/search_mock_data_source.dart';
import '../../manager/search_flow_cubit.dart';

class ProcessingViewBody extends StatefulWidget {
  const ProcessingViewBody({super.key, required this.requestId});

  final String requestId;

  @override
  State<ProcessingViewBody> createState() => _ProcessingViewBodyState();
}

class _ProcessingViewBodyState extends State<ProcessingViewBody> {
  late final Timer _messageTimer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _messageTimer = Timer.periodic(
      SearchMockDataSource.processingMessageDelay,
      (_) {
        if (!mounted) return;
        setState(() {
          _messageIndex =
              (_messageIndex + 1) % AppStrings.processingStatusMessages.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    super.dispose();
  }

  int _percentForProgress(double progress) {
    if (progress <= 0) return 0;
    for (final step in SearchMockDataSource.processingProgressSteps) {
      if (progress <= step) {
        return (step * 100).round();
      }
    }
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchFlowCubit, SearchFlowState>(
      listener: (context, state) {
        if (state.status == SearchFlowStatus.resultsReady) {
          context.go(AppRoutes.searchResultsFor(widget.requestId));
        }
      },
      child: BlocBuilder<SearchFlowCubit, SearchFlowState>(
        builder: (context, state) {
          final percent = _percentForProgress(state.progress);
          final circleValue = percent / 100;
          final message = AppStrings.processingStatusMessages[_messageIndex];

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Center(
                      child: Text(
                        AppStrings.appName,
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    SizedBox(
                      width: 240.w,
                      height: 240.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 240.w,
                            height: 240.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 220.w,
                            height: 220.w,
                            child: CircularProgressIndicator(
                              value: circleValue,
                              strokeWidth: 4,
                              color: AppColors.primary,
                              backgroundColor: AppColors.border,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percent%',
                                style: GoogleFonts.inter(
                                  fontSize: 44.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                AppStrings.processing,
                                style: AppStyle.labelCaps.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        message,
                        key: ValueKey(message),
                        textAlign: TextAlign.center,
                        style: AppStyle.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 48.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
