import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../manager/search_flow_cubit.dart';
import 'widgets/processing_view_body.dart';

class ProcessingView extends StatefulWidget {
  const ProcessingView({super.key, required this.requestId});

  final String requestId;

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapPipeline());
  }

  void _bootstrapPipeline() {
    if (!mounted) return;

    final cubit = context.read<SearchFlowCubit>();
    final state = cubit.state;

    if (state.status == SearchFlowStatus.resultsReady &&
        state.requestId == widget.requestId) {
      context.go(AppRoutes.searchResultsFor(widget.requestId));
      return;
    }

    cubit.startOffersPipeline(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return ProcessingViewBody(requestId: widget.requestId);
  }
}
