using System.Text;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Infrastructure.Services;

public sealed class GarmentAffiliateQueryBuilder : IAffiliateQueryBuilder
{
    public AffiliateSearchQuery Build(string requestId, GarmentTags tags, string countryCode)
    {
        var keywords = BuildKeywords(tags);
        return new AffiliateSearchQuery(
            requestId,
            tags,
            countryCode.Trim().ToUpperInvariant(),
            keywords);
    }

    private static string BuildKeywords(GarmentTags tags)
    {
        var parts = new[] { tags.Color, tags.Style, tags.Category }
            .Where(part => !string.IsNullOrWhiteSpace(part))
            .Select(part => part.Trim());

        return string.Join(' ', parts);
    }
}
