using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class AffiliateFanOutSearchService : IAffiliateFanOutSearchService
{
    private readonly IReadOnlyList<IAffiliateProviderClient> _providers;
    private readonly AffiliateSearchOptions _options;
    private readonly ILogger<AffiliateFanOutSearchService> _logger;

    public AffiliateFanOutSearchService(
        IReadOnlyList<IAffiliateProviderClient> providers,
        IOptions<AffiliateSearchOptions> options,
        ILogger<AffiliateFanOutSearchService> logger)
    {
        _providers = providers;
        _options = options.Value;
        _logger = logger;
    }

    public async IAsyncEnumerable<AffiliateProviderSearchResult> SearchProvidersAsCompletedAsync(
        AffiliateSearchQuery query,
        [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        if (_providers.Count == 0)
        {
            _logger.LogWarning("No affiliate providers are registered.");
            yield break;
        }

        var pending = _providers
            .Select(provider => SearchProviderWithTimeoutAsync(provider, query, cancellationToken))
            .ToList();

        while (pending.Count > 0)
        {
            var completedTask = await Task.WhenAny(pending);
            pending.Remove(completedTask);
            yield return await completedTask;
        }
    }

    private async Task<AffiliateProviderSearchResult> SearchProviderWithTimeoutAsync(
        IAffiliateProviderClient provider,
        AffiliateSearchQuery query,
        CancellationToken cancellationToken)
    {
        using var timeoutCts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        timeoutCts.CancelAfter(TimeSpan.FromSeconds(_options.ProviderTimeoutSeconds));

        try
        {
            return await provider.SearchAsync(query, timeoutCts.Token);
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            _logger.LogWarning(
                "Affiliate provider timed out. Provider={Provider}, RequestId={RequestId}.",
                provider.ProviderName,
                query.RequestId);

            return new AffiliateProviderSearchResult(
                provider.ProviderName,
                Success: false,
                Offers: [],
                FailureReason: "provider_timeout");
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Affiliate provider failed. Provider={Provider}, RequestId={RequestId}.",
                provider.ProviderName,
                query.RequestId);

            return new AffiliateProviderSearchResult(
                provider.ProviderName,
                Success: false,
                Offers: [],
                FailureReason: ex.Message);
        }
    }
}
