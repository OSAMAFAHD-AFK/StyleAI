namespace StyleAI.Infrastructure.Options;

public sealed class SkimlinksOptions
{
    public const string SectionName = "Skimlinks";

    public string ProductKey { get; set; } = string.Empty;

    public int PublisherId { get; set; }

    public string ProductApiBaseUrl { get; set; } = "http://api-product.skimlinks.com/";

    public int TimeoutSeconds { get; set; } = 5;

    public int MaxRows { get; set; } = 40;

    public string DefaultSearchCountry { get; set; } = "us";

    public Dictionary<string, string> CountryCodeMappings { get; set; } = new(StringComparer.OrdinalIgnoreCase)
    {
        ["SA"] = "us",
        ["AE"] = "us",
        ["KW"] = "us",
        ["QA"] = "us",
        ["BH"] = "us",
        ["OM"] = "us",
        ["US"] = "us",
        ["GB"] = "uk",
        ["UK"] = "uk"
    };
}
