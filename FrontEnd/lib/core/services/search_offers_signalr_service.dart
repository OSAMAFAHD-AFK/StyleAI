import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../models/affiliate_product_offer.dart';
import '../models/offers_search_summary.dart';
import '../utils/app_constants.dart';

/// Streams affiliate offers from [/hubs/search-offers] — mirrors backend hub events.
class SearchOffersSignalRService {
  HubConnection? _connection;
  final _offerController = StreamController<AffiliateProductOffer>.broadcast();
  final _completedController =
      StreamController<OffersSearchSummary?>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  Stream<AffiliateProductOffer> get offers => _offerController.stream;
  Stream<OffersSearchSummary?> get searchCompleted =>
      _completedController.stream;
  Stream<double> get progress => _progressController.stream;

  Future<void> connectAndJoin({
    required String requestId,
    required void Function(double) onProgress,
  }) async {
    await disconnect();

    final hubUrl =
        '${AppConstants.apiBaseUrl}${AppConstants.signalRHubPath}';

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            skipNegotiation: false,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('OfferReceived', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final map = Map<String, dynamic>.from(arguments[0] as Map);
      final offer = AffiliateProductOffer.fromJson(map);
      _offerController.add(offer);
      onProgress(0.85);
    });

    _connection!.on('OffersCatchUp', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final map = Map<String, dynamic>.from(arguments[0] as Map);
      final offers = (map['offers'] as List<dynamic>? ?? [])
          .map((e) => AffiliateProductOffer.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
      for (final offer in offers) {
        _offerController.add(offer);
      }
    });

    _connection!.on('SearchCompleted', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final map = Map<String, dynamic>.from(arguments[0] as Map);
      final summaryJson = map['summary'];
      final summary = summaryJson != null
          ? OffersSearchSummary.fromJson(
              Map<String, dynamic>.from(summaryJson as Map),
            )
          : null;
      _completedController.add(summary);
      onProgress(1.0);
    });

    _connection!.on('SearchStarted', (_) {
      onProgress(0.2);
    });

    _connection!.on('ProviderSearchCompleted', (_) {
      onProgress(0.6);
    });

    await _connection!.start();
    await _connection!.invoke('JoinSearchGroup', args: [requestId]);
  }

  Future<void> leaveGroup(String requestId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      await _connection!.invoke('LeaveSearchGroup', args: [requestId]);
    }
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }

  void dispose() {
    _offerController.close();
    _completedController.close();
    _progressController.close();
  }
}
