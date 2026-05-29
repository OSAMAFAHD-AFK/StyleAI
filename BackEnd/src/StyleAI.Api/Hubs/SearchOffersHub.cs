using Microsoft.AspNetCore.SignalR;

namespace StyleAI.Api.Hubs;

public sealed class SearchOffersHub : Hub
{
    public const string OfferReceivedEvent = "OfferReceived";
    public const string SearchCompletedEvent = "SearchCompleted";

    public Task JoinSearchGroup(string requestId)
    {
        if (string.IsNullOrWhiteSpace(requestId))
        {
            throw new HubException("requestId is required.");
        }

        return Groups.AddToGroupAsync(Context.ConnectionId, BuildGroupName(requestId));
    }

    public Task LeaveSearchGroup(string requestId)
    {
        if (string.IsNullOrWhiteSpace(requestId))
        {
            throw new HubException("requestId is required.");
        }

        return Groups.RemoveFromGroupAsync(Context.ConnectionId, BuildGroupName(requestId));
    }

    public static string BuildGroupName(string requestId) => $"search:{requestId}";
}
