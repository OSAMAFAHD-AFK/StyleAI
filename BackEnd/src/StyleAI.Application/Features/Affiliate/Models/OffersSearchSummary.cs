namespace StyleAI.Application.Features.Affiliate.Models;

public sealed record OffersSearchSummary(
    decimal? BenchmarkLocalizedPrice,
    decimal? CheapestDupeLocalizedPrice,
    decimal? MaxSavings,
    decimal? MaxSavingsPercent,
    string Currency,
    int TotalOffers,
    int OriginalCount,
    int DupeCount);
