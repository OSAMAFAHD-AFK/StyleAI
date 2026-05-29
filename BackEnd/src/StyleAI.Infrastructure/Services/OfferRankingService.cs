using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class OfferRankingService : IOfferRankingService
{
    private readonly OfferRankingOptions _options;

    public OfferRankingService(IOptions<OfferRankingOptions> options)
    {
        _options = options.Value;
    }

    public RankedOffersResult Rank(string requestId, IReadOnlyList<AffiliateProductOffer> offers)
    {
        if (offers.Count == 0)
        {
            return EmptyResult(requestId);
        }

        var benchmarkCandidate = SelectBenchmark(offers);
        var benchmarkPrice = benchmarkCandidate?.LocalizedPrice ?? 0m;
        var currency = benchmarkCandidate?.LocalizedCurrency
            ?? offers[0].LocalizedCurrency;

        var originals = offers
            .Where(o => o.OfferId != benchmarkCandidate?.OfferId && IsPremiumMerchant(o.MerchantSlug))
            .OrderByDescending(o => o.LocalizedPrice)
            .Take(_options.MaxOriginals)
            .Select((o, index) => EnrichOffer(o, OfferKinds.Original, benchmarkPrice, index + 1))
            .ToList();

        var dupes = offers
            .Where(o => o.OfferId != benchmarkCandidate?.OfferId && !IsPremiumMerchant(o.MerchantSlug))
            .OrderBy(o => o.LocalizedPrice)
            .Take(_options.MaxDupes)
            .Select((o, index) => EnrichOffer(o, OfferKinds.Dupe, benchmarkPrice, index + 1))
            .ToList();

        var priceMatches = offers
            .Where(o => o.OfferId != benchmarkCandidate?.OfferId && IsPriceMatch(o, benchmarkCandidate))
            .OrderBy(o => o.LocalizedPrice)
            .Select((o, index) => EnrichOffer(o, OfferKinds.PriceMatch, benchmarkPrice, index + 1))
            .ToList();

        AffiliateProductOffer? benchmark = null;
        if (benchmarkCandidate is not null)
        {
            benchmark = benchmarkCandidate with
            {
                OfferKind = OfferKinds.Benchmark,
                IsBenchmark = true,
                SavedAmount = 0,
                SavingsPercent = 0,
                DisplayRank = 0
            };
        }

        var allOffers = new List<AffiliateProductOffer>();
        if (benchmark is not null)
        {
            allOffers.Add(benchmark);
        }

        allOffers.AddRange(originals);
        allOffers.AddRange(dupes);
        allOffers.AddRange(priceMatches.Where(pm => !dupes.Any(d => d.OfferId == pm.OfferId)));

        var cheapestDupe = dupes.FirstOrDefault();
        var maxSavings = dupes.Count > 0 && benchmarkPrice > 0
            ? dupes.Max(d => d.SavedAmount ?? 0)
            : (decimal?)null;
        var maxSavingsPercent = dupes.Count > 0 && benchmarkPrice > 0
            ? dupes.Max(d => d.SavingsPercent ?? 0)
            : (decimal?)null;

        var summary = new OffersSearchSummary(
            BenchmarkLocalizedPrice: benchmarkPrice > 0 ? benchmarkPrice : null,
            CheapestDupeLocalizedPrice: cheapestDupe?.LocalizedPrice,
            MaxSavings: maxSavings,
            MaxSavingsPercent: maxSavingsPercent,
            Currency: currency,
            TotalOffers: allOffers.Count,
            OriginalCount: originals.Count + (benchmark is not null ? 1 : 0),
            DupeCount: dupes.Count);

        return new RankedOffersResult(
            requestId,
            benchmark,
            originals,
            dupes,
            priceMatches,
            summary,
            allOffers);
    }

    private AffiliateProductOffer? SelectBenchmark(IReadOnlyList<AffiliateProductOffer> offers)
    {
        var premiumOffers = offers
            .Where(o => IsPremiumMerchant(o.MerchantSlug))
            .OrderByDescending(o => o.LocalizedPrice)
            .ToList();

        if (premiumOffers.Count > 0)
        {
            return premiumOffers[0];
        }

        return offers.OrderByDescending(o => o.LocalizedPrice).FirstOrDefault();
    }

    private bool IsPremiumMerchant(string merchantSlug)
    {
        return _options.PremiumMerchantSlugs.Contains(merchantSlug);
    }

    private static bool IsPriceMatch(AffiliateProductOffer offer, AffiliateProductOffer? benchmark)
    {
        if (benchmark is null)
        {
            return false;
        }

        if (string.Equals(offer.MerchantSlug, benchmark.MerchantSlug, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return string.Equals(offer.ComparisonTitle, benchmark.ComparisonTitle, StringComparison.Ordinal);
    }

    private static AffiliateProductOffer EnrichOffer(
        AffiliateProductOffer offer,
        string offerKind,
        decimal benchmarkPrice,
        int displayRank)
    {
        decimal? saved = null;
        decimal? percent = null;

        if (benchmarkPrice > 0 && offer.LocalizedPrice < benchmarkPrice)
        {
            saved = Math.Round(benchmarkPrice - offer.LocalizedPrice, 2);
            percent = Math.Round(saved.Value / benchmarkPrice * 100m, 1);
        }

        return offer with
        {
            OfferKind = offerKind,
            IsBenchmark = false,
            SavedAmount = saved,
            SavingsPercent = percent,
            DisplayRank = displayRank
        };
    }

    private static RankedOffersResult EmptyResult(string requestId)
    {
        var summary = new OffersSearchSummary(
            null,
            null,
            null,
            null,
            "USD",
            0,
            0,
            0);

        return new RankedOffersResult(
            requestId,
            null,
            [],
            [],
            [],
            summary,
            []);
    }
}
