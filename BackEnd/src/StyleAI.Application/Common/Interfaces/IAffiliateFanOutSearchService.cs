using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IAffiliateFanOutSearchService
{
    IAsyncEnumerable<AffiliateProviderSearchResult> SearchProvidersAsCompletedAsync(
        AffiliateSearchQuery query,
        CancellationToken cancellationToken = default);
}
