using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Infrastructure.Affiliate;
using StyleAI.Infrastructure.Options;
using StyleAI.Infrastructure.Persistence;
using StyleAI.Infrastructure.Services;

namespace StyleAI.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "Connection string 'DefaultConnection' is not configured.");

        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(connectionString, npgsql =>
                npgsql.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName)));

        services.AddScoped<IApplicationDbContext>(provider =>
            provider.GetRequiredService<AppDbContext>());

        BindOptions(services, configuration);

        services.AddSingleton<ISearchResultStore, InMemorySearchResultStore>();
        services.AddScoped<IYoloDetectionService, YoloDetectionService>();
        services.AddScoped<IImageSearchPipelineService, ImageSearchPipelineService>();
        services.AddScoped<IUserContextService, UserContextService>();
        services.AddScoped<ISearchLogWriter, SearchLogWriter>();
        services.AddScoped<ISearchOrchestrationService, SearchOrchestrationService>();

        services.AddSingleton<IOfferResultStore, InMemoryOfferResultStore>();
        services.AddScoped<IAffiliateQueryBuilder, GarmentAffiliateQueryBuilder>();
        services.AddScoped<IAffiliateFanOutSearchService, AffiliateFanOutSearchService>();
        services.AddScoped<IAffiliateOfferSearchOrchestrator, AffiliateOfferSearchOrchestrator>();
        services.AddScoped<ColorNormalizationService>();
        services.AddScoped<SizeNormalizationService>();
        services.AddScoped<CurrencyConversionService>();
        services.AddScoped<IProductNormalizationService, ProductNormalizationService>();
        services.AddScoped<MerchantNormalizationService>();
        services.AddScoped<IOfferRankingService, OfferRankingService>();
        services.AddScoped<ISkimlinksAffiliateLinkBuilder, SkimlinksAffiliateLinkBuilder>();
        services.AddScoped<IAffiliatePurchaseRedirectService, AffiliatePurchaseRedirectService>();
        services.AddScoped<IThriftCounterService, ThriftCounterService>();
        services.AddScoped<IAffiliateConversionWebhookService, AffiliateConversionWebhookService>();
        services.AddScoped<SkimlinksMockAffiliateClient>();

        services.AddHttpClient<SkimlinksAffiliateClient>((sp, client) =>
        {
            var skimlinksOptions = sp.GetRequiredService<IOptions<SkimlinksOptions>>().Value;
            client.BaseAddress = new Uri(skimlinksOptions.ProductApiBaseUrl);
            client.Timeout = TimeSpan.FromSeconds(skimlinksOptions.TimeoutSeconds);
        });

        services.AddScoped<IAffiliateProviderClient>(sp =>
        {
            var skimlinksOptions = sp.GetRequiredService<IOptions<SkimlinksOptions>>().Value;
            var affiliateSearchOptions = sp.GetRequiredService<IOptions<AffiliateSearchOptions>>().Value;

            if (!string.IsNullOrWhiteSpace(skimlinksOptions.ProductKey))
            {
                return sp.GetRequiredService<SkimlinksAffiliateClient>();
            }

            if (affiliateSearchOptions.UseMockWhenProductKeyMissing)
            {
                return sp.GetRequiredService<SkimlinksMockAffiliateClient>();
            }

            return sp.GetRequiredService<SkimlinksAffiliateClient>();
        });

        services.AddScoped<IEnumerable<IAffiliateProviderClient>>(sp => [sp.GetRequiredService<IAffiliateProviderClient>()]);
        services.AddScoped<IReadOnlyList<IAffiliateProviderClient>>(sp =>
            sp.GetRequiredService<IEnumerable<IAffiliateProviderClient>>().ToList());

        services.AddHttpClient<IGeminiTagExtractionService, GeminiTagExtractionService>((sp, client) =>
        {
            var geminiOptions = sp.GetRequiredService<IOptions<GeminiOptions>>().Value;
            client.BaseAddress = new Uri(geminiOptions.BaseUrl);
            client.Timeout = TimeSpan.FromSeconds(geminiOptions.TimeoutSeconds);
        });

        return services;
    }

    private static void BindOptions(IServiceCollection services, IConfiguration configuration)
    {
        var imageProcessingOptions =
            configuration.GetSection(ImageProcessingOptions.SectionName).Get<ImageProcessingOptions>()
            ?? new ImageProcessingOptions();
        var yoloOptions =
            configuration.GetSection(YoloOptions.SectionName).Get<YoloOptions>()
            ?? new YoloOptions();
        var geminiOptions =
            configuration.GetSection(GeminiOptions.SectionName).Get<GeminiOptions>()
            ?? new GeminiOptions();
        var userContextOptions =
            configuration.GetSection(UserContextOptions.SectionName).Get<UserContextOptions>()
            ?? new UserContextOptions();
        var skimlinksOptions =
            configuration.GetSection(SkimlinksOptions.SectionName).Get<SkimlinksOptions>()
            ?? new SkimlinksOptions();
        var affiliateSearchOptions =
            configuration.GetSection(AffiliateSearchOptions.SectionName).Get<AffiliateSearchOptions>()
            ?? new AffiliateSearchOptions();
        var normalizationOptions =
            configuration.GetSection(NormalizationOptions.SectionName).Get<NormalizationOptions>()
            ?? new NormalizationOptions();
        var offerRankingOptions =
            configuration.GetSection(OfferRankingOptions.SectionName).Get<OfferRankingOptions>()
            ?? new OfferRankingOptions();
        var monetizationOptions =
            configuration.GetSection(MonetizationOptions.SectionName).Get<MonetizationOptions>()
            ?? new MonetizationOptions();

        services.AddSingleton<IOptions<ImageProcessingOptions>>(
            Microsoft.Extensions.Options.Options.Create(imageProcessingOptions));
        services.AddSingleton<IOptions<YoloOptions>>(
            Microsoft.Extensions.Options.Options.Create(yoloOptions));
        services.AddSingleton<IOptions<GeminiOptions>>(
            Microsoft.Extensions.Options.Options.Create(geminiOptions));
        services.AddSingleton<IOptions<UserContextOptions>>(
            Microsoft.Extensions.Options.Options.Create(userContextOptions));
        services.AddSingleton<IOptions<SkimlinksOptions>>(
            Microsoft.Extensions.Options.Options.Create(skimlinksOptions));
        services.AddSingleton<IOptions<AffiliateSearchOptions>>(
            Microsoft.Extensions.Options.Options.Create(affiliateSearchOptions));
        services.AddSingleton<IOptions<NormalizationOptions>>(
            Microsoft.Extensions.Options.Options.Create(normalizationOptions));
        services.AddSingleton<IOptions<OfferRankingOptions>>(
            Microsoft.Extensions.Options.Options.Create(offerRankingOptions));
        services.AddSingleton<IOptions<MonetizationOptions>>(
            Microsoft.Extensions.Options.Options.Create(monetizationOptions));
    }
}
