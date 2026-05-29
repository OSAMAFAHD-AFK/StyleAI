namespace StyleAI.Application.Features.Monetization.Models;

public sealed record PreparePurchaseRedirectCommand(
    string RequestId,
    string OfferId,
    string? DeviceToken);
