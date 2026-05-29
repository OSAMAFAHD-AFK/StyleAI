using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Streaming.Models;

namespace StyleAI.Api.Services;

public sealed class SearchOffersCatchUpService : ISearchOffersCatchUpService
{
    private readonly IOfferResultStore _offerResultStore;

    public SearchOffersCatchUpService(IOfferResultStore offerResultStore)
    {
        _offerResultStore = offerResultStore;
    }

    public async Task<OffersCatchUpNotification?> BuildCatchUpAsync(
        string requestId,
        CancellationToken cancellationToken = default)
    {
        var session = await _offerResultStore.GetSessionAsync(requestId, cancellationToken);
        if (session is null)
        {
            return null;
        }

        var ranked = await _offerResultStore.GetRankedResultAsync(requestId, cancellationToken);
        var offers = ranked?.AllOffers ?? await _offerResultStore.GetOffersAsync(requestId, cancellationToken);
        var isComplete = session.Status is OffersStatus.Completed
            or OffersStatus.Failed
            or OffersStatus.Unavailable;

        return new OffersCatchUpNotification(
            requestId,
            session.Status,
            offers,
            ranked?.Summary,
            isComplete);
    }
}
