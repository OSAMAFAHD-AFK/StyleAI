namespace StyleAI.Application.Features.Monetization.Models;

public sealed record ThriftCounterSummary(
    Guid UserId,
    decimal TotalSavings,
    string Currency,
    int TotalClicks,
    int ConvertedClicks);
