using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IOfferQualityFilter
{
    bool IsValid(AffiliateProductOffer offer);

    bool TryRegisterUnique(AffiliateProductOffer offer);
}
