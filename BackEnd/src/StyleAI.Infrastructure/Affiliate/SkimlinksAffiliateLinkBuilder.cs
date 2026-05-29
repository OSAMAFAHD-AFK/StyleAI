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

    public string WrapProductUrl(string productUrl, Guid? affiliateTrackingId = null)
    {
        if (string.IsNullOrWhiteSpace(productUrl))
        {
            return productUrl;
        }

        if (_options.PublisherId <= 0)
        {
            return AppendTrackingQuery(productUrl, affiliateTrackingId);
        }

        string wrappedUrl;
        if (productUrl.Contains("skimresources.com", StringComparison.OrdinalIgnoreCase) ||
            productUrl.Contains("go.redirectingat.com", StringComparison.OrdinalIgnoreCase))
        {
            wrappedUrl = productUrl;
        }
        else if (!Uri.TryCreate(productUrl, UriKind.Absolute, out var uri) ||
                 uri.Scheme is not "http" and not "https")
        {
            return productUrl;
        }
        else
        {
            wrappedUrl =
                $"https://go.skimresources.com/?id={_options.PublisherId}&url={Uri.EscapeDataString(productUrl)}";
        }

        return AppendTrackingQuery(wrappedUrl, affiliateTrackingId);
    }

    private string AppendTrackingQuery(string url, Guid? affiliateTrackingId)
    {
        if (affiliateTrackingId is null || string.IsNullOrWhiteSpace(_options.CustomTrackingQueryParameter))
        {
            return url;
        }

        var separator = url.Contains('?', StringComparison.Ordinal) ? '&' : '?';
        return $"{url}{separator}{_options.CustomTrackingQueryParameter}={affiliateTrackingId:D}";
    }
}
