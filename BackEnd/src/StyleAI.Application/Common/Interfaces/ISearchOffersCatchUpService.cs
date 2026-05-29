using StyleAI.Application.Features.Streaming.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface ISearchOffersCatchUpService
{
    Task<OffersCatchUpNotification?> BuildCatchUpAsync(
        string requestId,
        CancellationToken cancellationToken = default);
}
