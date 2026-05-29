namespace StyleAI.Infrastructure.Options;

public sealed class NormalizationOptions
{
    public const string SectionName = "Normalization";

    public string BaseCurrency { get; set; } = "USD";

    public Dictionary<string, string> CountryCurrencies { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["SA"] = "SAR",
        ["AE"] = "AED",
        ["KW"] = "KWD",
        ["QA"] = "QAR",
        ["BH"] = "BHD",
        ["OM"] = "OMR",
        ["US"] = "USD",
        ["GB"] = "GBP",
        ["UK"] = "GBP"
    };

    public Dictionary<string, decimal> ExchangeRatesFromUsd { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["USD"] = 1m,
        ["SAR"] = 3.75m,
        ["AED"] = 3.67m,
        ["KWD"] = 0.31m,
        ["QAR"] = 3.64m,
        ["BHD"] = 0.38m,
        ["OMR"] = 0.38m,
        ["GBP"] = 0.79m,
        ["EUR"] = 0.92m
    };

    public Dictionary<string, string> ColorAliases { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["crimson"] = "red",
        ["burgundy"] = "red",
        ["wine"] = "red",
        ["maroon"] = "red",
        ["ivory"] = "white",
        ["cream"] = "white",
        ["off-white"] = "white",
        ["navy"] = "blue",
        ["teal"] = "blue",
        ["charcoal"] = "gray",
        ["grey"] = "gray",
        ["beige"] = "brown",
        ["tan"] = "brown"
    };

    public Dictionary<string, string> UsToEuSizes { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["XS"] = "34",
        ["S"] = "36",
        ["M"] = "38",
        ["L"] = "40",
        ["XL"] = "42",
        ["XXL"] = "44"
    };

    public Dictionary<string, string> UsToGccSizes { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["XS"] = "XS",
        ["S"] = "S",
        ["M"] = "M",
        ["L"] = "L",
        ["XL"] = "XL",
        ["XXL"] = "XXL"
    };
}
