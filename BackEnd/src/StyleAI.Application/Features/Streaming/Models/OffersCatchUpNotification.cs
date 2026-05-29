using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Features.Streaming.Models;

/// <summary>
/// Sent when a client joins a search group mid-flight or after reconnect.
/// </summary>
public sealed record OffersCatchUpNotification(
    string RequestId,
    string Status,
    IReadOnlyList<AffiliateProductOffer> Offers,
    OffersSearchSummary? Summary,
    bool IsSearchComplete);
