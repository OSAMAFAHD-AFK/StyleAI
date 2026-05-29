using System.Threading.Channels;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Application.Features.Streaming.Models;
using StyleAI.Infrastructure.Affiliate;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class AffiliateOfferSearchOrchestrator : IAffiliateOfferSearchOrchestrator
{
    private readonly ISearchResultStore _searchResultStore;
    private readonly IOfferResultStore _offerResultStore;
    private readonly IAffiliateQueryBuilder _affiliateQueryBuilder;
    private readonly IServiceScopeFactory _serviceScopeFactory;
    private readonly AffiliateSearchOptions _affiliateSearchOptions;
    private readonly OfferRankingOptions _offerRankingOptions;
    private readonly ILogger<AffiliateOfferSearchOrchestrator> _logger;

    public AffiliateOfferSearchOrchestrator(
        ISearchResultStore searchResultStore,
        IOfferResultStore offerResultStore,
        IAffiliateQueryBuilder affiliateQueryBuilder,
        IServiceScopeFactory serviceScopeFactory,
        IOptions<AffiliateSearchOptions> affiliateSearchOptions,
        IOptions<OfferRankingOptions> offerRankingOptions,
        ILogger<AffiliateOfferSearchOrchestrator> logger)
    {
        _searchResultStore = searchResultStore;
        _offerResultStore = offerResultStore;
        _affiliateQueryBuilder = affiliateQueryBuilder;
        _serviceScopeFactory = serviceScopeFactory;
        _affiliateSearchOptions = affiliateSearchOptions.Value;
        _offerRankingOptions = offerRankingOptions.Value;
        _logger = logger;
    }

    public async Task<bool> TryStartSearchAsync(
        string requestId,
        string countryCode,
        CancellationToken cancellationToken = default)
    {
        var uploadResult = await _searchResultStore.GetAsync(requestId, cancellationToken);
        if (uploadResult?.Tags is null || uploadResult.TagsStatus != TagsStatus.Available)
        {
            return false;
        }

        var existingSession = await _offerResultStore.GetSessionAsync(requestId, cancellationToken);
        if (existingSession?.Status == OffersStatus.Running)
        {
            return true;
        }

        await _offerResultStore.InitializeSessionAsync(
            requestId,
            uploadResult.SearchLogId,
            cancellationToken);

        var query = _affiliateQueryBuilder.Build(requestId, uploadResult.Tags, countryCode);

        _ = Task.Run(
            () => ExecuteSearchAsync(query, uploadResult.Tags.Color, CancellationToken.None),
            CancellationToken.None);

        _logger.LogInformation(
            "Affiliate offer search started. RequestId={RequestId}, Country={Country}, Keywords={Keywords}, SearchLogId={SearchLogId}.",
            requestId,
            countryCode,
            query.Keywords,
            uploadResult.SearchLogId);

        return true;
    }

    private async Task ExecuteSearchAsync(
        AffiliateSearchQuery query,
        string normalizedColor,
        CancellationToken cancellationToken)
    {
        var offerChannel = Channel.CreateBounded<AffiliateProductOffer>(new BoundedChannelOptions(
            _affiliateSearchOptions.StreamChannelCapacity)
        {
            FullMode = BoundedChannelFullMode.Wait,
            SingleReader = true,
            SingleWriter = false
        });

        try
        {
            await using var scope = _serviceScopeFactory.CreateAsyncScope();
            var fanOut = scope.ServiceProvider.GetRequiredService<IAffiliateFanOutSearchService>();
            var normalization = scope.ServiceProvider.GetRequiredService<IProductNormalizationService>();
            var offerStore = scope.ServiceProvider.GetRequiredService<IOfferResultStore>();
            var streamPublisher = scope.ServiceProvider.GetRequiredService<IOfferStreamPublisher>();
            var rankingService = scope.ServiceProvider.GetRequiredService<IOfferRankingService>();
            var linkBuilder = scope.ServiceProvider.GetRequiredService<ISkimlinksAffiliateLinkBuilder>();
            var skimlinksOptions = scope.ServiceProvider.GetRequiredService<IOptions<SkimlinksOptions>>().Value;
            var useMockStreamDelay = string.IsNullOrWhiteSpace(skimlinksOptions.ProductKey) &&
                                     _affiliateSearchOptions.MockStreamDelayMilliseconds > 0;

            var qualityFilter = new OfferQualityFilter();
            var collectedOffers = new List<AffiliateProductOffer>();
            var rollingBenchmarkPrice = 0m;
            var searchStartedAt = DateTimeOffset.UtcNow;

            await streamPublisher.PublishSearchStartedAsync(
                new SearchStartedNotification(
                    query.RequestId,
                    query.CountryCode,
                    query.Keywords,
                    searchStartedAt),
                cancellationToken);

            var publishTask = PublishOffersFromChannelAsync(
                offerChannel.Reader,
                offerStore,
                streamPublisher,
                cancellationToken);

            var sequence = 0;
            var publishedCount = 0;
            var successfulProviders = 0;
            var failedProviders = 0;

            await foreach (var providerResult in fanOut.SearchProvidersAsCompletedAsync(query, cancellationToken))
            {
                var providerOfferCount = 0;

                if (!providerResult.Success)
                {
                    failedProviders++;
                    _logger.LogWarning(
                        "Affiliate provider returned no offers. Provider={Provider}, Reason={Reason}, RequestId={RequestId}.",
                        providerResult.Provider,
                        providerResult.FailureReason,
                        query.RequestId);

                    await streamPublisher.PublishProviderSearchCompletedAsync(
                        new ProviderSearchCompletedNotification(
                            query.RequestId,
                            providerResult.Provider,
                            Success: false,
                            OfferCount: 0,
                            DurationMilliseconds: providerResult.DurationMilliseconds,
                            providerResult.FailureReason),
                        cancellationToken);
                    continue;
                }

                successfulProviders++;

                foreach (var rawOffer in providerResult.Offers)
                {
                    if (publishedCount >= _affiliateSearchOptions.MaxOffersPerSearch)
                    {
                        break;
                    }

                    sequence++;
                    var normalized = normalization.Normalize(
                        rawOffer,
                        query.RequestId,
                        providerResult.Provider,
                        query.CountryCode,
                        normalizedColor,
                        sequence);

                    var wrappedUrl = linkBuilder.WrapProductUrl(normalized.ProductUrl);
                    normalized = normalized with { ProductUrl = wrappedUrl };

                    if (!qualityFilter.IsValid(normalized) || !qualityFilter.TryRegisterUnique(normalized))
                    {
                        continue;
                    }

                    if (normalized.LocalizedPrice > rollingBenchmarkPrice)
                    {
                        rollingBenchmarkPrice = normalized.LocalizedPrice;
                    }

                    var streamOffer = EnrichForStream(normalized, rollingBenchmarkPrice);
                    collectedOffers.Add(streamOffer);

                    await offerChannel.Writer.WriteAsync(streamOffer, cancellationToken);
                    publishedCount++;
                    providerOfferCount++;

                    if (useMockStreamDelay)
                    {
                        await Task.Delay(_affiliateSearchOptions.MockStreamDelayMilliseconds, cancellationToken);
                    }
                }

                await streamPublisher.PublishProviderSearchCompletedAsync(
                    new ProviderSearchCompletedNotification(
                        query.RequestId,
                        providerResult.Provider,
                        Success: true,
                        OfferCount: providerOfferCount,
                        DurationMilliseconds: providerResult.DurationMilliseconds),
                    cancellationToken);
            }

            offerChannel.Writer.TryComplete();
            await publishTask;

            var status = publishedCount > 0
                ? OffersStatus.Completed
                : failedProviders > 0 && successfulProviders == 0
                    ? OffersStatus.Unavailable
                    : OffersStatus.Failed;

            var failureReason = publishedCount > 0
                ? null
                : failedProviders > 0
                    ? "all_providers_failed"
                    : "no_offers_from_providers";

            OffersSearchSummary? summary = null;
            if (collectedOffers.Count > 0)
            {
                var ranked = rankingService.Rank(query.RequestId, collectedOffers);
                await offerStore.ReplaceOffersAsync(
                    query.RequestId,
                    ranked.AllOffers,
                    ranked,
                    cancellationToken);
                summary = ranked.Summary;

                _logger.LogInformation(
                    "Offers ranked. RequestId={RequestId}, Benchmark={HasBenchmark}, Originals={Originals}, Dupes={Dupes}, MaxSavings={MaxSavings}.",
                    query.RequestId,
                    ranked.Benchmark is not null,
                    ranked.Originals.Count,
                    ranked.Dupes.Count,
                    ranked.Summary.MaxSavings);
            }

            await offerStore.CompleteSessionAsync(query.RequestId, status, failureReason, cancellationToken);
            await streamPublisher.PublishSearchCompletedAsync(
                new SearchCompletedNotification(
                    query.RequestId,
                    status,
                    publishedCount,
                    summary,
                    failureReason),
                cancellationToken);

            _logger.LogInformation(
                "Affiliate offer search completed. RequestId={RequestId}, PublishedOffers={Count}, Status={Status}.",
                query.RequestId,
                publishedCount,
                status);
        }
        catch (Exception ex)
        {
            offerChannel.Writer.TryComplete(ex);
            _logger.LogError(ex, "Affiliate offer search crashed. RequestId={RequestId}.", query.RequestId);

            await using var scope = _serviceScopeFactory.CreateAsyncScope();
            var offerStore = scope.ServiceProvider.GetRequiredService<IOfferResultStore>();
            var streamPublisher = scope.ServiceProvider.GetRequiredService<IOfferStreamPublisher>();

            await offerStore.CompleteSessionAsync(
                query.RequestId,
                OffersStatus.Failed,
                ex.Message,
                cancellationToken);

            await streamPublisher.PublishSearchCompletedAsync(
                new SearchCompletedNotification(
                    query.RequestId,
                    OffersStatus.Failed,
                    0,
                    null,
                    ex.Message),
                cancellationToken);
        }
    }

    private AffiliateProductOffer EnrichForStream(AffiliateProductOffer offer, decimal rollingBenchmarkPrice)
    {
        var isPremium = _offerRankingOptions.PremiumMerchantSlugs.Contains(offer.MerchantSlug);
        var offerKind = isPremium ? OfferKinds.Original : OfferKinds.Dupe;

        decimal? saved = null;
        decimal? percent = null;

        if (rollingBenchmarkPrice > 0 && offer.LocalizedPrice < rollingBenchmarkPrice)
        {
            saved = Math.Round(rollingBenchmarkPrice - offer.LocalizedPrice, 2);
            percent = Math.Round(saved.Value / rollingBenchmarkPrice * 100m, 1);
        }

        return offer with
        {
            OfferKind = offerKind,
            SavedAmount = saved,
            SavingsPercent = percent
        };
    }

    private static async Task PublishOffersFromChannelAsync(
        ChannelReader<AffiliateProductOffer> reader,
        IOfferResultStore offerStore,
        IOfferStreamPublisher streamPublisher,
        CancellationToken cancellationToken)
    {
        await foreach (var offer in reader.ReadAllAsync(cancellationToken))
        {
            await offerStore.AppendOfferAsync(offer, cancellationToken);
            await streamPublisher.PublishOfferAsync(offer, cancellationToken);
        }
    }
}
