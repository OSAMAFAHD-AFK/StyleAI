using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IAffiliateQueryBuilder
{
    AffiliateSearchQuery Build(string requestId, GarmentTags tags, string countryCode);
}
