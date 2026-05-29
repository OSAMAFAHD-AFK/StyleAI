namespace StyleAI.Application.Features.Monetization.Models;

public sealed record AffiliateConversionWebhookRequest(
    Guid? AffiliateTrackingId,
    string? ExternalTransactionId,
    decimal? CommissionAmount,
    string? Currency,
    string Provider);
