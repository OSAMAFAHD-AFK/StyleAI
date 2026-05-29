using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Features.Streaming.Models;

public sealed record SearchCompletedNotification(
    string RequestId,
    string Status,
    int TotalOffers,
    OffersSearchSummary? Summary,
    string? FailureReason = null);
