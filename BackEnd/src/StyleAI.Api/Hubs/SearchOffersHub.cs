using Microsoft.AspNetCore.SignalR;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Streaming.Models;

namespace StyleAI.Api.Hubs;

public sealed class SearchOffersHub : Hub<ISearchOffersHubClient>
{
    private readonly ISearchOffersCatchUpService _catchUpService;
    private readonly ILogger<SearchOffersHub> _logger;

    public SearchOffersHub(
        ISearchOffersCatchUpService catchUpService,
        ILogger<SearchOffersHub> logger)
    {
        _catchUpService = catchUpService;
        _logger = logger;
    }

    public async Task JoinSearchGroup(string requestId)
    {
        var normalizedRequestId = NormalizeRequestId(requestId);
        await Groups.AddToGroupAsync(Context.ConnectionId, BuildGroupName(normalizedRequestId));

        _logger.LogDebug(
            "Client joined search group. ConnectionId={ConnectionId}, RequestId={RequestId}.",
            Context.ConnectionId,
            normalizedRequestId);

        var catchUp = await _catchUpService.BuildCatchUpAsync(normalizedRequestId, Context.ConnectionAborted);
        if (catchUp is null || catchUp.Offers.Count == 0 && !catchUp.IsSearchComplete)
        {
            return;
        }

        await Clients.Caller.OffersCatchUp(catchUp);

        if (catchUp.IsSearchComplete && catchUp.Summary is not null)
        {
            await Clients.Caller.SearchCompleted(new SearchCompletedNotification(
                catchUp.RequestId,
                catchUp.Status,
                catchUp.Offers.Count,
                catchUp.Summary));
        }
    }

    public Task LeaveSearchGroup(string requestId)
    {
        var normalizedRequestId = NormalizeRequestId(requestId);
        _logger.LogDebug(
            "Client left search group. ConnectionId={ConnectionId}, RequestId={RequestId}.",
            Context.ConnectionId,
            normalizedRequestId);

        return Groups.RemoveFromGroupAsync(Context.ConnectionId, BuildGroupName(normalizedRequestId));
    }

    public static string BuildGroupName(string requestId) => $"search:{requestId}";

    private static string NormalizeRequestId(string requestId)
    {
        if (string.IsNullOrWhiteSpace(requestId))
        {
            throw new HubException("requestId is required.");
        }

        return requestId.Trim();
    }
}
