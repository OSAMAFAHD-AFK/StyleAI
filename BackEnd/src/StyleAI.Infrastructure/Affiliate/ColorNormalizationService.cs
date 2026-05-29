using Microsoft.Extensions.Options;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Affiliate;

public sealed class ColorNormalizationService
{
    private readonly NormalizationOptions _options;

    public ColorNormalizationService(IOptions<NormalizationOptions> options)
    {
        _options = options.Value;
    }

    public string Normalize(string? color, string fallbackColor)
    {
        if (string.IsNullOrWhiteSpace(color))
        {
            return Normalize(fallbackColor, "unknown");
        }

        var trimmed = color.Trim().ToLowerInvariant();
        if (_options.ColorAliases.TryGetValue(trimmed, out var mapped))
        {
            return mapped;
        }

        return trimmed;
    }
}
