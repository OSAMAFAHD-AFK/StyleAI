using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Monetization.Models;
using StyleAI.Infrastructure.Options;
using StyleAI.Infrastructure.Persistence;

namespace StyleAI.Infrastructure.Services;

public sealed class AffiliateConversionWebhookService : IAffiliateConversionWebhookService
{
    private readonly AppDbContext _dbContext;
    private readonly ILogger<AffiliateConversionWebhookService> _logger;

    public AffiliateConversionWebhookService(
        AppDbContext dbContext,
        ILogger<AffiliateConversionWebhookService> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task<AffiliateConversionWebhookResult> ProcessAsync(
        AffiliateConversionWebhookRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.AffiliateTrackingId is null)
        {
            return new AffiliateConversionWebhookResult(
                Accepted: false,
                Message: "affiliateTrackingId is required.",
                AffiliateTrackingId: null);
        }

        var click = await _dbContext.ClickTrackings
            .FirstOrDefaultAsync(
                tracking => tracking.AffiliateTrackingId == request.AffiliateTrackingId.Value,
                cancellationToken);

        if (click is null)
        {
            return new AffiliateConversionWebhookResult(
                Accepted: false,
                Message: "Tracking id was not found.",
                request.AffiliateTrackingId);
        }

        if (click.IsConverted)
        {
            return new AffiliateConversionWebhookResult(
                Accepted: true,
                Message: "Conversion already recorded.",
                click.AffiliateTrackingId);
        }

        click.IsConverted = true;
        click.ConvertedAt = DateTimeOffset.UtcNow;
        click.CommissionAmount = request.CommissionAmount is > 0
            ? Math.Round(request.CommissionAmount.Value, 2)
            : click.CommissionAmount;

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Affiliate conversion recorded. TrackingId={TrackingId}, Provider={Provider}, Commission={Commission}.",
            click.AffiliateTrackingId,
            request.Provider,
            click.CommissionAmount);

        return new AffiliateConversionWebhookResult(
            Accepted: true,
            Message: "Conversion recorded.",
            click.AffiliateTrackingId);
    }
}
