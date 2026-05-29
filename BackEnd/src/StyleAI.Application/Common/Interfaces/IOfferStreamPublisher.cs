using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Streaming.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IOfferStreamPublisher
{
    Task PublishSearchStartedAsync(
        SearchStartedNotification notification,
        CancellationToken cancellationToken = default);

    Task PublishOfferAsync(AffiliateProductOffer offer, CancellationToken cancellationToken = default);

    Task PublishProviderSearchCompletedAsync(
        ProviderSearchCompletedNotification notification,
        CancellationToken cancellationToken = default);

    Task PublishSearchCompletedAsync(
        SearchCompletedNotification notification,
        CancellationToken cancellationToken = default);
}
