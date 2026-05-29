namespace StyleAI.Application.Features.Streaming.Models;

public sealed record ProviderSearchCompletedNotification(
    string RequestId,
    string Provider,
    bool Success,
    int OfferCount,
    long DurationMilliseconds,
    string? FailureReason = null);
