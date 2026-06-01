import 'package:flutter/material.dart';

import 'widgets/search_results_view_body.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return SearchResultsViewBody(requestId: requestId);
  }
}
