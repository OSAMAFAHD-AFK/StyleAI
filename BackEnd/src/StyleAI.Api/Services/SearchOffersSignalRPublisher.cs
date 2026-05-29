using Microsoft.AspNetCore.SignalR;
using StyleAI.Api.Hubs;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Streaming.Models;

namespace StyleAI.Api.Services;

public sealed class SearchOffersSignalRPublisher : IOfferStreamPublisher
{
    private readonly IHubContext<SearchOffersHub, ISearchOffersHubClient> _hubContext;
    private readonly ILogger<SearchOffersSignalRPublisher> _logger;

    public SearchOffersSignalRPublisher(
        IHubContext<SearchOffersHub, ISearchOffersHubClient> hubContext,
        ILogger<SearchOffersSignalRPublisher> logger)
    {
        _hubContext = hubContext;
        _logger = logger;
    }

    public Task PublishSearchStartedAsync(
        SearchStartedNotification notification,
        CancellationToken cancellationToken = default)
    {
        return SendToSearchGroupAsync(
            notification.RequestId,
            client => client.SearchStarted(notification),
            cancellationToken);
    }

    public Task PublishOfferAsync(AffiliateProductOffer offer, CancellationToken cancellationToken = default)
    {
        return SendToSearchGroupAsync(
            offer.RequestId,
            client => client.OfferReceived(offer),
            cancellationToken);
    }

    public Task PublishProviderSearchCompletedAsync(
        ProviderSearchCompletedNotification notification,
        CancellationToken cancellationToken = default)
    {
        return SendToSearchGroupAsync(
            notification.RequestId,
            client => client.ProviderSearchCompleted(notification),
            cancellationToken);
    }

    public Task PublishSearchCompletedAsync(
        SearchCompletedNotification notification,
        CancellationToken cancellationToken = default)
    {
        return SendToSearchGroupAsync(
            notification.RequestId,
            client => client.SearchCompleted(notification),
            cancellationToken);
    }

    private async Task SendToSearchGroupAsync(
        string requestId,
        Func<ISearchOffersHubClient, Task> sendAction,
        CancellationToken cancellationToken)
    {
        try
        {
            await sendAction(_hubContext.Clients.Group(SearchOffersHub.BuildGroupName(requestId)));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(
                ex,
                "SignalR publish failed. RequestId={RequestId}.",
                requestId);
        }
    }
}
