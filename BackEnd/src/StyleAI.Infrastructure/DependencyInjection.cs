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

        var imageProcessingOptions =
            configuration.GetSection(ImageProcessingOptions.SectionName).Get<ImageProcessingOptions>()
            ?? new ImageProcessingOptions();
        var yoloOptions =
            configuration.GetSection(YoloOptions.SectionName).Get<YoloOptions>()
            ?? new YoloOptions();

        services.AddSingleton<IOptions<ImageProcessingOptions>>(
            Microsoft.Extensions.Options.Options.Create(imageProcessingOptions));
        services.AddSingleton<IOptions<YoloOptions>>(
            Microsoft.Extensions.Options.Options.Create(yoloOptions));

        services.AddSingleton<ISearchResultStore, InMemorySearchResultStore>();
        services.AddScoped<IYoloDetectionService, YoloDetectionService>();
        services.AddScoped<IImageSearchPipelineService, ImageSearchPipelineService>();

        return services;
    }
}
