using Microsoft.Extensions.Options;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Affiliate;

public sealed class SizeNormalizationService
{
    private readonly NormalizationOptions _options;

    public SizeNormalizationService(IOptions<NormalizationOptions> options)
    {
        _options = options.Value;
    }

    public string? Normalize(string? size, string countryCode)
    {
        if (string.IsNullOrWhiteSpace(size))
        {
            return null;
        }

        var normalizedSize = size.Trim().ToUpperInvariant();
        var country = countryCode.Trim().ToUpperInvariant();

        if (country is "GB" or "UK" or "FR" or "DE" or "EU")
        {
            return _options.UsToEuSizes.TryGetValue(normalizedSize, out var euSize)
                ? euSize
                : normalizedSize;
        }

        if (country is "SA" or "AE" or "KW" or "QA" or "BH" or "OM")
        {
            return _options.UsToGccSizes.TryGetValue(normalizedSize, out var gccSize)
                ? gccSize
                : normalizedSize;
        }

        return normalizedSize;
    }
}
