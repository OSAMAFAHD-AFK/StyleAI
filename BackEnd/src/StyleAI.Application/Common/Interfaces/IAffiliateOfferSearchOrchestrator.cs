namespace StyleAI.Application.Common.Interfaces;

public interface IAffiliateOfferSearchOrchestrator
{
    Task<bool> TryStartSearchAsync(
        string requestId,
        string countryCode,
        CancellationToken cancellationToken = default);
}
