using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IOfferRankingService
{
    RankedOffersResult Rank(string requestId, IReadOnlyList<AffiliateProductOffer> offers);
}
