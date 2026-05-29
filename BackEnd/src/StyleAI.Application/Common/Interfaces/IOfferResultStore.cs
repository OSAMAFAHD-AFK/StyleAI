using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IOfferResultStore
{
    Task<AffiliateSearchSession?> GetSessionAsync(string requestId, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AffiliateProductOffer>> GetOffersAsync(string requestId, CancellationToken cancellationToken = default);

    Task<AffiliateProductOffer?> GetOfferAsync(
        string requestId,
        string offerId,
        CancellationToken cancellationToken = default);

    Task InitializeSessionAsync(
        string requestId,
        long? searchLogId = null,
        CancellationToken cancellationToken = default);

    Task AppendOfferAsync(AffiliateProductOffer offer, CancellationToken cancellationToken = default);

    Task ReplaceOffersAsync(
        string requestId,
        IReadOnlyList<AffiliateProductOffer> offers,
        RankedOffersResult rankedResult,
        CancellationToken cancellationToken = default);

    Task<RankedOffersResult?> GetRankedResultAsync(
        string requestId,
        CancellationToken cancellationToken = default);

    Task CompleteSessionAsync(
        string requestId,
        string status,
        string? failureReason = null,
        CancellationToken cancellationToken = default);
}
