using System.Diagnostics;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;

namespace StyleAI.Infrastructure.Services;

/// <summary>
/// Stand-in for Skimlinks Product API until ProductKey is configured (Managed tier).
/// </summary>
public sealed class SkimlinksMockAffiliateClient : IAffiliateProviderClient
{
    private static readonly string[] MerchantNames =
    [
        "SHEIN",
        "Amazon",
        "AliExpress",
        "ASOS",
        "Zara"
    ];

    public string ProviderName => "skimlinks";

    public async Task<AffiliateProviderSearchResult> SearchAsync(
        AffiliateSearchQuery query,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        await Task.Delay(Random.Shared.Next(300, 900), cancellationToken);

        var offers = new List<RawAffiliateOffer>();
        var basePrice = 18m + Random.Shared.Next(5, 40);

        for (var index = 0; index < 12; index++)
        {
            var merchant = MerchantNames[index % MerchantNames.Length];
            var price = basePrice + index * 3.5m;
            offers.Add(new RawAffiliateOffer(
                ExternalId: $"{query.RequestId}:{index}",
                Title: $"{query.Tags.Style} {query.Tags.Color} {query.Tags.Category} - {merchant}",
                Description: $"Skimlinks mock offer for: {query.Keywords}",
                MerchantName: merchant,
                ProductUrl: $"https://example.com/products/{query.RequestId}/{index}",
                ImageUrl: null,
                Price: price,
                Currency: "USD",
                Size: index % 2 == 0 ? "M" : "L",
                Color: query.Tags.Color,
                SourceCountry: query.CountryCode));
        }

        return new AffiliateProviderSearchResult(
            ProviderName,
            Success: true,
            Offers: offers,
            DurationMilliseconds: stopwatch.ElapsedMilliseconds);
    }
}
