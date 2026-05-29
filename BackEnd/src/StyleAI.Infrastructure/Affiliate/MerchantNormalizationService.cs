namespace StyleAI.Infrastructure.Affiliate;

public sealed class MerchantNormalizationService
{
    public string NormalizeSlug(string merchantName)
    {
        if (string.IsNullOrWhiteSpace(merchantName))
        {
            return "unknown";
        }

        var normalized = merchantName.Trim().ToLowerInvariant();

        if (normalized.Contains("shein", StringComparison.Ordinal))
        {
            return "shein";
        }

        if (normalized.Contains("amazon", StringComparison.Ordinal))
        {
            return "amazon";
        }

        if (normalized.Contains("aliexpress", StringComparison.Ordinal) ||
            normalized.Contains("ali express", StringComparison.Ordinal))
        {
            return "aliexpress";
        }

        if (normalized.Contains("asos", StringComparison.Ordinal))
        {
            return "asos";
        }

        if (normalized.Contains("zara", StringComparison.Ordinal))
        {
            return "zara";
        }

        return normalized
            .Replace(" ", "-", StringComparison.Ordinal)
            .Replace(".", "-", StringComparison.Ordinal);
    }
}
