using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Infrastructure.Affiliate;

public sealed class OfferQualityFilter : IOfferQualityFilter
{
    private readonly HashSet<string> _seenUrls = new(StringComparer.OrdinalIgnoreCase);

    public bool IsValid(AffiliateProductOffer offer)
    {
        if (string.IsNullOrWhiteSpace(offer.ProductUrl))
        {
            return false;
        }

        if (offer.LocalizedPrice <= 0 && offer.Price <= 0)
        {
            return false;
        }

        return true;
    }

    public bool TryRegisterUnique(AffiliateProductOffer offer)
    {
        var key = NormalizeUrl(offer.ProductUrl);
        return _seenUrls.Add(key);
    }

    private static string NormalizeUrl(string url)
    {
        if (!Uri.TryCreate(url.Trim(), UriKind.Absolute, out var uri))
        {
            return url.Trim().ToLowerInvariant();
        }

        var builder = new UriBuilder(uri)
        {
            Query = string.Empty,
            Fragment = string.Empty
        };

        return builder.Uri.ToString().TrimEnd('/').ToLowerInvariant();
    }
}
