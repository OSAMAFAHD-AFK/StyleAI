namespace StyleAI.Application.Features.Monetization.Models;

public sealed record AffiliateConversionWebhookResult(
    bool Accepted,
    string? Message,
    Guid? AffiliateTrackingId);
