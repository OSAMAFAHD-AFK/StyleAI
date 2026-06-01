import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../manager/search_flow_cubit.dart';
import 'search_results_view.dart';
import 'widgets/capture_analysis_view_body.dart';
import 'widgets/search_empty_view_body.dart';

class CaptureAnalysisView extends StatefulWidget {
  const CaptureAnalysisView({super.key});

  @override
  State<CaptureAnalysisView> createState() => _CaptureAnalysisViewState();
}

class _CaptureAnalysisViewState extends State<CaptureAnalysisView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToResultsIfNeeded());
  }

  void _redirectToResultsIfNeeded() {
    if (!mounted) return;

    final state = context.read<SearchFlowCubit>().state;
    if (state.hasCompletedResults) {
      context.go(AppRoutes.searchResultsFor(state.requestId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchFlowCubit, SearchFlowState>(
      listenWhen: (previous, current) =>
          previous.hasCompletedResults != current.hasCompletedResults,
      listener: (context, state) {
        if (state.hasCompletedResults) {
          context.go(AppRoutes.searchResultsFor(state.requestId!));
        }
      },
      child: BlocBuilder<SearchFlowCubit, SearchFlowState>(
        builder: (context, state) {
          if (state.hasCompletedResults) {
            return SearchResultsView(requestId: state.requestId!);
          }

          if (!state.hasActiveSession) {
            return const SearchEmptyViewBody();
          }

          return const CaptureAnalysisViewBody();
        },
      ),
    );
  }
}
