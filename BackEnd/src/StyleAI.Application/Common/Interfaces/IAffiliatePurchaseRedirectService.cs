using StyleAI.Application.Features.Monetization.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IAffiliatePurchaseRedirectService
{
    Task<PreparedPurchaseRedirect> PrepareRedirectAsync(
        PreparePurchaseRedirectCommand command,
        CancellationToken cancellationToken = default);

    Task<string> ResolveMerchantDestinationUrlAsync(
        Guid affiliateTrackingId,
        CancellationToken cancellationToken = default);
}
