namespace StyleAI.Infrastructure.Options;

public sealed class OfferRankingOptions
{
    public const string SectionName = "OfferRanking";

    public HashSet<string> PremiumMerchantSlugs { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        "asos",
        "zara",
        "namshi",
        "nordstrom",
        "farfetch",
        "revolve",
        "bloomingdales",
        "mango",
        "h&m",
        "hm"
    };

    public int MaxOriginals { get; set; } = 12;

    public int MaxDupes { get; set; } = 50;

    public decimal PriceMatchTitleSimilarityThreshold { get; set; } = 0.85m;
}
