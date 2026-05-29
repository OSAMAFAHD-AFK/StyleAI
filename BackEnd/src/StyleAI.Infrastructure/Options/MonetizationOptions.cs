namespace StyleAI.Infrastructure.Options;

public sealed class MonetizationOptions
{
    public const string SectionName = "Monetization";

    public string WebhookSecret { get; set; } = string.Empty;

    public int RedirectRateLimitPerMinute { get; set; } = 120;
}
