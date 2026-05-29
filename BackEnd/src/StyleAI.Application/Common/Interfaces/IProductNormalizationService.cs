using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IProductNormalizationService
{
    AffiliateProductOffer Normalize(
        RawAffiliateOffer raw,
        string requestId,
        string provider,
        string targetCountryCode,
        string normalizedColor,
        int sequenceNumber);
}
