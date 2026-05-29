using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Monetization.Models;
using StyleAI.Domain.Entities;
using StyleAI.Infrastructure.Persistence;

namespace StyleAI.Infrastructure.Services;

public sealed class AffiliatePurchaseRedirectService : IAffiliatePurchaseRedirectService
{
    private readonly AppDbContext _dbContext;
    private readonly IUserContextService _userContextService;
    private readonly IOfferResultStore _offerResultStore;
    private readonly ISkimlinksAffiliateLinkBuilder _affiliateLinkBuilder;
    private readonly ILogger<AffiliatePurchaseRedirectService> _logger;

    public AffiliatePurchaseRedirectService(
        AppDbContext dbContext,
        IUserContextService userContextService,
        IOfferResultStore offerResultStore,
        ISkimlinksAffiliateLinkBuilder affiliateLinkBuilder,
        ILogger<AffiliatePurchaseRedirectService> logger)
    {
        _dbContext = dbContext;
        _userContextService = userContextService;
        _offerResultStore = offerResultStore;
        _affiliateLinkBuilder = affiliateLinkBuilder;
        _logger = logger;
    }

    public async Task<PreparedPurchaseRedirect> PrepareRedirectAsync(
        PreparePurchaseRedirectCommand command,
        CancellationToken cancellationToken = default)
    {
        var requestId = command.RequestId.Trim();
        var offerId = command.OfferId.Trim();

        var offer = await _offerResultStore.GetOfferAsync(requestId, offerId, cancellationToken)
            ?? throw new InvalidOperationException("Offer not found for this search session.");

        var session = await _offerResultStore.GetSessionAsync(requestId, cancellationToken);
        if (session?.SearchLogId is null)
        {
            throw new InvalidOperationException("Search log is not available for this offer.");
        }

        var searchLog = await _dbContext.SearchLogs
            .AsNoTracking()
            .FirstOrDefaultAsync(log => log.Id == session.SearchLogId.Value, cancellationToken)
            ?? throw new InvalidOperationException("Search log record was not found.");

        var ranked = await _offerResultStore.GetRankedResultAsync(requestId, cancellationToken);
        var originalPrice = ResolveBenchmarkPrice(ranked, offer);
        var dupePrice = offer.LocalizedPrice;
        var savedAmount = Math.Max(0, Math.Round(originalPrice - dupePrice, 2));
        var currency = offer.LocalizedCurrency;

        var userProfile = await _userContextService.GetOrCreateUserAsync(command.DeviceToken, cancellationToken);
        var user = await _dbContext.Users.FirstAsync(u => u.Id == userProfile.Id, cancellationToken);
        var affiliateTrackingId = Guid.NewGuid();
        var monetizedUrl = _affiliateLinkBuilder.WrapProductUrl(offer.ProductUrl, affiliateTrackingId);
        var now = DateTimeOffset.UtcNow;

        var click = new ClickTracking
        {
            UserId = user.Id,
            SearchLogId = searchLog.Id,
            AffiliateTrackingId = affiliateTrackingId,
            TargetMerchant = offer.MerchantSlug,
            TargetProductUrl = monetizedUrl,
            TargetProductImageUrl = offer.ImageUrl,
            OriginalPrice = originalPrice,
            DupePrice = dupePrice,
            SavedAmount = savedAmount,
            Currency = currency,
            IsConverted = false,
            ClickedAt = now
        };

        _dbContext.ClickTrackings.Add(click);

        user.TotalSavings = Math.Round(user.TotalSavings + savedAmount, 2);
        user.UpdatedAt = now;
        user.LastSeenAt = now;

        _dbContext.Users.Update(user);
        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Purchase redirect prepared. TrackingId={TrackingId}, UserId={UserId}, SavedAmount={SavedAmount}, Merchant={Merchant}.",
            affiliateTrackingId,
            user.Id,
            savedAmount,
            offer.MerchantSlug);

        return new PreparedPurchaseRedirect(
            affiliateTrackingId,
            $"/api/redirect/{affiliateTrackingId:D}",
            savedAmount,
            currency,
            user.TotalSavings);
    }

    public async Task<string> ResolveMerchantDestinationUrlAsync(
        Guid affiliateTrackingId,
        CancellationToken cancellationToken = default)
    {
        var click = await _dbContext.ClickTrackings
            .AsNoTracking()
            .FirstOrDefaultAsync(
                tracking => tracking.AffiliateTrackingId == affiliateTrackingId,
                cancellationToken);

        if (click is null || string.IsNullOrWhiteSpace(click.TargetProductUrl))
        {
            throw new KeyNotFoundException("Affiliate tracking id was not found.");
        }

        return click.TargetProductUrl;
    }

    private static decimal ResolveBenchmarkPrice(RankedOffersResult? ranked, AffiliateProductOffer offer)
    {
        if (ranked?.Benchmark is not null)
        {
            return ranked.Benchmark.LocalizedPrice;
        }

        if (ranked?.Summary.BenchmarkLocalizedPrice is > 0)
        {
            return ranked.Summary.BenchmarkLocalizedPrice.Value;
        }

        if (offer.SavedAmount is > 0)
        {
            return offer.LocalizedPrice + offer.SavedAmount.Value;
        }

        return offer.LocalizedPrice;
    }
}
