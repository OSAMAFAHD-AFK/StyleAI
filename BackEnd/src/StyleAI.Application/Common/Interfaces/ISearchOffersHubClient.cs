using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Streaming.Models;

namespace StyleAI.Application.Common.Interfaces;

/// <summary>
/// Typed SignalR client contract for the search-offers hub.
/// Method names map directly to event names on the Flutter client.
/// </summary>
public interface ISearchOffersHubClient
{
    Task SearchStarted(SearchStartedNotification notification);

    Task OfferReceived(AffiliateProductOffer offer);

    Task ProviderSearchCompleted(ProviderSearchCompletedNotification notification);

    Task OffersCatchUp(OffersCatchUpNotification notification);

    Task SearchCompleted(SearchCompletedNotification notification);
}
