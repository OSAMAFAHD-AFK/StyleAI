namespace StyleAI.Infrastructure.Options;

public sealed class AffiliateSearchOptions
{
    public const string SectionName = "AffiliateSearch";

    public int ProviderTimeoutSeconds { get; set; } = 5;

    public bool UseMockWhenProductKeyMissing { get; set; } = true;

    public int MaxOffersPerSearch { get; set; } = 100;

    public int StreamChannelCapacity { get; set; } = 128;

    public int MockStreamDelayMilliseconds { get; set; } = 80;

    public int OffersRateLimitPerMinute { get; set; } = 60;
}
