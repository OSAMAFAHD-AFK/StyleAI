namespace StyleAI.Application.Features.Affiliate.Models;

public sealed record RankedOffersResult(
    string RequestId,
    AffiliateProductOffer? Benchmark,
    IReadOnlyList<AffiliateProductOffer> Originals,
    IReadOnlyList<AffiliateProductOffer> Dupes,
    IReadOnlyList<AffiliateProductOffer> PriceMatches,
    OffersSearchSummary Summary,
    IReadOnlyList<AffiliateProductOffer> AllOffers);
