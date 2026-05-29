using System.Diagnostics;
using System.Net;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class SkimlinksAffiliateClient : IAffiliateProviderClient
{
    private readonly HttpClient _httpClient;
    private readonly SkimlinksOptions _options;
    private readonly ILogger<SkimlinksAffiliateClient> _logger;

    public SkimlinksAffiliateClient(
        HttpClient httpClient,
        IOptions<SkimlinksOptions> options,
        ILogger<SkimlinksAffiliateClient> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public string ProviderName => "skimlinks";

    public async Task<AffiliateProviderSearchResult> SearchAsync(
        AffiliateSearchQuery query,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();

        if (string.IsNullOrWhiteSpace(_options.ProductKey))
        {
            return new AffiliateProviderSearchResult(
                ProviderName,
                Success: false,
                Offers: [],
                FailureReason: "Skimlinks ProductKey is not configured.",
                DurationMilliseconds: stopwatch.ElapsedMilliseconds);
        }

        try
        {
            var skimCountry = ResolveSkimlinksCountry(query.CountryCode);
            var solrQuery = BuildSolrQuery(query.Keywords, skimCountry);
            var requestUri = BuildRequestUri(solrQuery);

            using var response = await _httpClient.GetAsync(requestUri, cancellationToken);
            var payload = await response.Content.ReadAsStringAsync(cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning(
                    "Skimlinks search failed. Status={StatusCode}, RequestId={RequestId}.",
                    (int)response.StatusCode,
                    query.RequestId);

                return new AffiliateProviderSearchResult(
                    ProviderName,
                    Success: false,
                    Offers: [],
                    FailureReason: $"Skimlinks HTTP {(int)response.StatusCode}.",
                    DurationMilliseconds: stopwatch.ElapsedMilliseconds);
            }

            var offers = ParseProducts(payload, query);

            return new AffiliateProviderSearchResult(
                ProviderName,
                Success: true,
                Offers: offers,
                DurationMilliseconds: stopwatch.ElapsedMilliseconds);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            _logger.LogError(ex, "Skimlinks search threw for RequestId={RequestId}.", query.RequestId);
            return new AffiliateProviderSearchResult(
                ProviderName,
                Success: false,
                Offers: [],
                FailureReason: ex.Message,
                DurationMilliseconds: stopwatch.ElapsedMilliseconds);
        }
    }

    private string ResolveSkimlinksCountry(string countryCode)
    {
        if (_options.CountryCodeMappings.TryGetValue(countryCode, out var mapped))
        {
            return mapped;
        }

        return _options.DefaultSearchCountry;
    }

    private static string BuildSolrQuery(string keywords, string skimCountry)
    {
        var escapedKeywords = EscapeSolr(keywords);
        var clauses = new List<string>
        {
            $"(title:\"{escapedKeywords}\" OR description:\"{escapedKeywords}\")"
        };

        if (!string.IsNullOrWhiteSpace(skimCountry))
        {
            clauses.Add($"country:\"{skimCountry}\"");
        }

        return string.Join(" AND ", clauses);
    }

    private string BuildRequestUri(string solrQuery)
    {
        var query = WebUtility.UrlEncode(solrQuery);
        var key = WebUtility.UrlEncode(_options.ProductKey);
        return $"query?format=json&key={key}&q={query}&rows={_options.MaxRows}";
    }

    private List<RawAffiliateOffer> ParseProducts(string payload, AffiliateSearchQuery query)
    {
        using var document = JsonDocument.Parse(payload);
        var root = document.RootElement;

        if (root.ValueKind == JsonValueKind.Array)
        {
            var message = root.EnumerateArray().FirstOrDefault().GetString();
            throw new InvalidOperationException(message ?? "Invalid Skimlinks API key or request.");
        }

        if (!root.TryGetProperty("skimlinksProductAPI", out var apiNode))
        {
            return [];
        }

        if (!apiNode.TryGetProperty("products", out var productsNode) ||
            productsNode.ValueKind != JsonValueKind.Array)
        {
            return [];
        }

        var results = new List<RawAffiliateOffer>();
        foreach (var product in productsNode.EnumerateArray())
        {
            var title = ReadString(product, "title");
            var url = ReadString(product, "url");
            if (string.IsNullOrWhiteSpace(title) || string.IsNullOrWhiteSpace(url))
            {
                continue;
            }

            var priceMinor = product.TryGetProperty("price", out var priceNode) && priceNode.TryGetInt32(out var minor)
                ? minor
                : 0;

            results.Add(new RawAffiliateOffer(
                ExternalId: ReadString(product, "id") ?? Guid.NewGuid().ToString("N"),
                Title: title,
                Description: ReadString(product, "description"),
                MerchantName: ReadString(product, "merchant") ?? "unknown",
                ProductUrl: url,
                ImageUrl: ReadString(product, "imageUrl"),
                Price: priceMinor / 100m,
                Currency: ReadString(product, "currency") ?? "usd",
                Size: null,
                Color: query.Tags.Color,
                SourceCountry: ReadString(product, "country") ?? query.CountryCode));
        }

        return results;
    }

    private static string? ReadString(JsonElement element, string propertyName)
    {
        if (!element.TryGetProperty(propertyName, out var value))
        {
            return null;
        }

        return value.ValueKind switch
        {
            JsonValueKind.String => value.GetString(),
            JsonValueKind.Number => value.GetRawText(),
            _ => null
        };
    }

    private static string EscapeSolr(string input)
    {
        return input
            .Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace("\"", "\\\"", StringComparison.Ordinal);
    }
}
