using Microsoft.AspNetCore.SignalR;
using StyleAI.Api.Hubs;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Api.Services;

public sealed class SignalROfferStreamPublisher : IOfferStreamPublisher
{
    private readonly IHubContext<SearchOffersHub> _hubContext;

    public SignalROfferStreamPublisher(IHubContext<SearchOffersHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public Task PublishOfferAsync(AffiliateProductOffer offer, CancellationToken cancellationToken = default)
    {
        return _hubContext.Clients
            .Group(SearchOffersHub.BuildGroupName(offer.RequestId))
            .SendAsync(SearchOffersHub.OfferReceivedEvent, offer, cancellationToken);
    }

    public Task PublishSearchCompletedAsync(
        string requestId,
        string status,
        int totalOffers,
        OffersSearchSummary? summary = null,
        string? failureReason = null,
        CancellationToken cancellationToken = default)
    {
        return _hubContext.Clients
            .Group(SearchOffersHub.BuildGroupName(requestId))
            .SendAsync(
                SearchOffersHub.SearchCompletedEvent,
                new
                {
                    requestId,
                    status,
                    totalOffers,
                    failureReason,
                    summary
                },
                cancellationToken);
    }
}
