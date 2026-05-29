using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Features.Affiliate.Models;

public sealed record AffiliateSearchQuery(
    string RequestId,
    GarmentTags Tags,
    string CountryCode,
    string Keywords);
