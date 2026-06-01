import 'package:equatable/equatable.dart';

class SearchHistoryItemModel extends Equatable {
  const SearchHistoryItemModel({
    required this.requestId,
    required this.timestampLabel,
    required this.title,
    required this.resultSummary,
    required this.searchType,
    required this.imageUrl,
  });

  final String requestId;
  final String timestampLabel;
  final String title;
  final String resultSummary;
  final String searchType;
  final String imageUrl;

  @override
  List<Object?> get props => [requestId, title, timestampLabel];
}
