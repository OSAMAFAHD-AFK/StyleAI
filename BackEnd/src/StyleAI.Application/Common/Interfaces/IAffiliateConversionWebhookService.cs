using StyleAI.Application.Features.Monetization.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IAffiliateConversionWebhookService
{
    Task<AffiliateConversionWebhookResult> ProcessAsync(
        AffiliateConversionWebhookRequest request,
        CancellationToken cancellationToken = default);
}
