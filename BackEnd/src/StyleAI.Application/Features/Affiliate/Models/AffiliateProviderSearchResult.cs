namespace StyleAI.Application.Features.Affiliate.Models;

public sealed record AffiliateProviderSearchResult(
    string Provider,
    bool Success,
    IReadOnlyList<RawAffiliateOffer> Offers,
    string? FailureReason = null,
    long DurationMilliseconds = 0);
