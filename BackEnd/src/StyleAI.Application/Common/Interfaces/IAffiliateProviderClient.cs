using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IAffiliateProviderClient
{
    string ProviderName { get; }

    Task<AffiliateProviderSearchResult> SearchAsync(
        AffiliateSearchQuery query,
        CancellationToken cancellationToken = default);
}
