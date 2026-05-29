namespace StyleAI.Application.Features.Monetization.Models;

public sealed record PreparedPurchaseRedirect(
    Guid AffiliateTrackingId,
    string RedirectPath,
    decimal SavedAmount,
    string Currency,
    decimal UpdatedTotalSavings);
