using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Http.Timeouts;
using System.Threading.RateLimiting;
using StyleAI.Api.Hubs;
using StyleAI.Api.Services;
using StyleAI.Api.Validation;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Infrastructure;
using StyleAI.Infrastructure.Options;
using StyleAI.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddSignalR();
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddScoped<IOfferStreamPublisher, SignalROfferStreamPublisher>();
builder.Services.AddSingleton<ImageUploadValidator>();

var imageProcessingOptions = builder.Configuration
    .GetSection(ImageProcessingOptions.SectionName)
    .Get<ImageProcessingOptions>() ?? new ImageProcessingOptions();
var affiliateSearchOptions = builder.Configuration
    .GetSection(AffiliateSearchOptions.SectionName)
    .Get<AffiliateSearchOptions>() ?? new AffiliateSearchOptions();

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddFixedWindowLimiter("upload-limiter", limiter =>
    {
        limiter.PermitLimit = imageProcessingOptions.RateLimitPerMinute;
        limiter.Window = TimeSpan.FromMinutes(1);
        limiter.QueueLimit = 0;
    });
    options.AddFixedWindowLimiter("offers-limiter", limiter =>
    {
        limiter.PermitLimit = affiliateSearchOptions.OffersRateLimitPerMinute;
        limiter.Window = TimeSpan.FromMinutes(1);
        limiter.QueueLimit = 0;
    });
});

builder.Services.AddRequestTimeouts(options =>
{
    options.AddPolicy("search-upload-timeout", TimeSpan.FromSeconds(imageProcessingOptions.RequestTimeoutSeconds));
});

builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>("database");

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseRateLimiter();
app.UseRequestTimeouts();
app.UseAuthorization();

app.MapControllers();
app.MapHub<SearchOffersHub>("/hubs/search-offers");
app.MapHealthChecks("/health");
app.MapGet("/api/db/ping", async (AppDbContext db, CancellationToken ct) =>
{
    var canConnect = await db.Database.CanConnectAsync(ct);
    return canConnect
        ? Results.Ok(new { status = "connected", provider = "PostgreSQL" })
        : Results.StatusCode(StatusCodes.Status503ServiceUnavailable);
});

app.Run();
