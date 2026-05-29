using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Affiliate;

public sealed class SkimlinksAffiliateLinkBuilder : ISkimlinksAffiliateLinkBuilder
{
    private readonly SkimlinksOptions _options;

    public SkimlinksAffiliateLinkBuilder(IOptions<SkimlinksOptions> options)
    {
        _options = options.Value;
    }

    public string WrapProductUrl(string productUrl)
    {
        if (_options.PublisherId <= 0 || string.IsNullOrWhiteSpace(productUrl))
        {
            return productUrl;
        }

        if (productUrl.Contains("skimresources.com", StringComparison.OrdinalIgnoreCase) ||
            productUrl.Contains("go.redirectingat.com", StringComparison.OrdinalIgnoreCase))
        {
            return productUrl;
        }

        if (!Uri.TryCreate(productUrl, UriKind.Absolute, out var uri) ||
            uri.Scheme is not "http" and not "https")
        {
            return productUrl;
        }

        return $"https://go.skimresources.com/?id={_options.PublisherId}&url={Uri.EscapeDataString(productUrl)}";
    }
}
