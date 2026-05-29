using StyleAI.Api.Options;
using StyleAI.Api.Services;
using StyleAI.Application.Common.Interfaces;

namespace StyleAI.Api.Extensions;

public static class SignalRServiceCollectionExtensions
{
    public static IServiceCollection AddSearchOffersSignalR(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var signalROptions = configuration
            .GetSection(SignalROptions.SectionName)
            .Get<SignalROptions>() ?? new SignalROptions();

        services.AddSingleton(Microsoft.Extensions.Options.Options.Create(signalROptions));
        services.AddScoped<ISearchOffersCatchUpService, SearchOffersCatchUpService>();
        services.AddScoped<IOfferStreamPublisher, SearchOffersSignalRPublisher>();

        services.AddSignalR(options =>
        {
            options.EnableDetailedErrors = true;
            options.KeepAliveInterval = TimeSpan.FromSeconds(signalROptions.KeepAliveIntervalSeconds);
            options.ClientTimeoutInterval = TimeSpan.FromSeconds(signalROptions.ClientTimeoutSeconds);
            options.HandshakeTimeout = TimeSpan.FromSeconds(signalROptions.HandshakeTimeoutSeconds);
            options.MaximumReceiveMessageSize = signalROptions.MaximumReceiveMessageSizeKb * 1024;
        });

        var corsOrigins = signalROptions.CorsOrigins;
        if (corsOrigins.Length > 0)
        {
            services.AddCors(options =>
            {
                options.AddPolicy("SignalRClientPolicy", policy =>
                {
                    policy.WithOrigins(corsOrigins)
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                });
            });
        }

        return services;
    }

    public static WebApplication UseSearchOffersSignalR(this WebApplication app)
    {
        var signalROptions = app.Services
            .GetRequiredService<Microsoft.Extensions.Options.IOptions<SignalROptions>>()
            .Value;

        if (signalROptions.CorsOrigins.Length > 0)
        {
            app.UseCors("SignalRClientPolicy");
        }

        app.MapHub<Hubs.SearchOffersHub>(signalROptions.HubPath);
        return app;
    }
}
