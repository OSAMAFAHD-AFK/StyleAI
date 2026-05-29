using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IOfferStreamPublisher
{
    Task PublishOfferAsync(AffiliateProductOffer offer, CancellationToken cancellationToken = default);

    Task PublishSearchCompletedAsync(
        string requestId,
        string status,
        int totalOffers,
        OffersSearchSummary? summary = null,
        string? failureReason = null,
        CancellationToken cancellationToken = default);
}
