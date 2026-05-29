using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Monetization.Models;

namespace StyleAI.Api.Controllers;

[ApiController]
[Route("api/redirect")]
public sealed class RedirectController : ControllerBase
{
    private const string DeviceTokenHeaderName = "X-Device-Token";

    private readonly IAffiliatePurchaseRedirectService _purchaseRedirectService;
    private readonly ILogger<RedirectController> _logger;

    public RedirectController(
        IAffiliatePurchaseRedirectService purchaseRedirectService,
        ILogger<RedirectController> logger)
    {
        _purchaseRedirectService = purchaseRedirectService;
        _logger = logger;
    }

    /// <summary>
    /// Prepares affiliate tracking, updates thrift counter, returns internal redirect path.
    /// Call this when the user taps "Buy" in the app.
    /// </summary>
    [HttpPost("prepare")]
    [EnableRateLimiting("redirect-limiter")]
    public async Task<IActionResult> PrepareRedirectAsync(
        [FromBody] PreparePurchaseRedirectRequest request,
        CancellationToken cancellationToken)
    {
        if (request is null ||
            string.IsNullOrWhiteSpace(request.RequestId) ||
            string.IsNullOrWhiteSpace(request.OfferId))
        {
            return BadRequest(new { error = "requestId and offerId are required." });
        }

        try
        {
            var deviceToken = Request.Headers[DeviceTokenHeaderName].FirstOrDefault()
                ?? request.DeviceToken;

            var prepared = await _purchaseRedirectService.PrepareRedirectAsync(
                new PreparePurchaseRedirectCommand(request.RequestId, request.OfferId, deviceToken),
                cancellationToken);

            return Ok(new
            {
                prepared.AffiliateTrackingId,
                redirectUrl = $"{Request.Scheme}://{Request.Host}{prepared.RedirectPath}",
                redirectPath = prepared.RedirectPath,
                prepared.SavedAmount,
                prepared.Currency,
                prepared.UpdatedTotalSavings
            });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { error = ex.Message });
        }
    }

    /// <summary>
    /// HTTP 302 to the monetized merchant URL. Idempotent — does not double-count savings.
    /// </summary>
    [HttpGet("{affiliateTrackingId:guid}")]
    [EnableRateLimiting("redirect-limiter")]
    public async Task<IActionResult> RedirectToMerchantAsync(
        Guid affiliateTrackingId,
        CancellationToken cancellationToken)
    {
        try
        {
            var destinationUrl = await _purchaseRedirectService.ResolveMerchantDestinationUrlAsync(
                affiliateTrackingId,
                cancellationToken);

            _logger.LogInformation(
                "Redirecting purchase click. TrackingId={TrackingId}.",
                affiliateTrackingId);

            return Redirect(destinationUrl);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { error = "Tracking id was not found or expired." });
        }
    }
}

public sealed record PreparePurchaseRedirectRequest(
    string RequestId,
    string OfferId,
    string? DeviceToken = null);
