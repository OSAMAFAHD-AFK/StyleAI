namespace StyleAI.Application.Features.Affiliate.Models;

public sealed record AffiliateSearchSession(
    string RequestId,
    string Status,
    int TotalOffers,
    DateTimeOffset StartedAt,
    DateTimeOffset? CompletedAt = null,
    string? FailureReason = null,
    long? SearchLogId = null);
