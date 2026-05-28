using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
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

        services.AddSingleton<IOptions<ImageProcessingOptions>>(
            Microsoft.Extensions.Options.Options.Create(imageProcessingOptions));
        services.AddSingleton<IOptions<YoloOptions>>(
            Microsoft.Extensions.Options.Options.Create(yoloOptions));
        services.AddSingleton<IOptions<GeminiOptions>>(
            Microsoft.Extensions.Options.Options.Create(geminiOptions));
        services.AddSingleton<IOptions<UserContextOptions>>(
            Microsoft.Extensions.Options.Options.Create(userContextOptions));
    }
}
