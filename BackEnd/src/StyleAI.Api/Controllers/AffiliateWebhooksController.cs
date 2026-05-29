using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Monetization.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Api.Controllers;

[ApiController]
[Route("api/webhooks/affiliate")]
public sealed class AffiliateWebhooksController : ControllerBase
{
    private const string WebhookSecretHeaderName = "X-Webhook-Secret";

    private readonly IAffiliateConversionWebhookService _webhookService;
    private readonly MonetizationOptions _monetizationOptions;

    public AffiliateWebhooksController(
        IAffiliateConversionWebhookService webhookService,
        IOptions<MonetizationOptions> monetizationOptions)
    {
        _webhookService = webhookService;
        _monetizationOptions = monetizationOptions.Value;
    }

    [HttpPost("skimlinks")]
    public Task<IActionResult> SkimlinksPostbackAsync(
        [FromBody] SkimlinksPostbackRequest? body,
        CancellationToken cancellationToken)
    {
        if (!IsAuthorized())
        {
            return Task.FromResult<IActionResult>(Unauthorized(new { error = "Invalid webhook secret." }));
        }

        var trackingId = body?.AffiliateTrackingId
            ?? body?.CustomId
            ?? ParseTrackingIdFromQuery();

        return ProcessPostbackAsync(
            new AffiliateConversionWebhookRequest(
                trackingId,
                body?.TransactionId,
                body?.CommissionAmount,
                body?.Currency,
                Provider: "skimlinks"),
            cancellationToken);
    }

    [HttpPost("conversion")]
    public Task<IActionResult> GenericConversionPostbackAsync(
        [FromBody] AffiliateConversionWebhookRequest request,
        CancellationToken cancellationToken)
    {
        if (!IsAuthorized())
        {
            return Task.FromResult<IActionResult>(Unauthorized(new { error = "Invalid webhook secret." }));
        }

        return ProcessPostbackAsync(request, cancellationToken);
    }

    private async Task<IActionResult> ProcessPostbackAsync(
        AffiliateConversionWebhookRequest request,
        CancellationToken cancellationToken)
    {
        var result = await _webhookService.ProcessAsync(request, cancellationToken);
        if (!result.Accepted)
        {
            return BadRequest(new { result.Message, result.AffiliateTrackingId });
        }

        return Ok(new { result.Message, result.AffiliateTrackingId });
    }

    private bool IsAuthorized()
    {
        if (string.IsNullOrWhiteSpace(_monetizationOptions.WebhookSecret))
        {
            return true;
        }

        if (Request.Headers.TryGetValue(WebhookSecretHeaderName, out var headerSecret) &&
            string.Equals(headerSecret.FirstOrDefault(), _monetizationOptions.WebhookSecret, StringComparison.Ordinal))
        {
            return true;
        }

        return Request.Query.TryGetValue("secret", out var querySecret) &&
               string.Equals(querySecret.FirstOrDefault(), _monetizationOptions.WebhookSecret, StringComparison.Ordinal);
    }

    private Guid? ParseTrackingIdFromQuery()
    {
        if (Request.Query.TryGetValue("affiliateTrackingId", out var trackingValue) &&
            Guid.TryParse(trackingValue.FirstOrDefault(), out var trackingId))
        {
            return trackingId;
        }

        if (Request.Query.TryGetValue("xcust", out var xcustValue) &&
            Guid.TryParse(xcustValue.FirstOrDefault(), out var xcustId))
        {
            return xcustId;
        }

        return null;
    }
}

public sealed record SkimlinksPostbackRequest(
    Guid? AffiliateTrackingId,
    Guid? CustomId,
    string? TransactionId,
    decimal? CommissionAmount,
    string? Currency);
