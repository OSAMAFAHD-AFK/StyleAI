using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Http.Timeouts;
using StyleAI.Api.Validation;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Infrastructure.Options;
using Microsoft.Extensions.Options;

namespace StyleAI.Api.Controllers;

[ApiController]
[Route("api/search")]
public class SearchController : ControllerBase
{
    private const string DeviceTokenHeaderName = "X-Device-Token";
    private const string CountryCodeHeaderName = "X-Country-Code";

    private readonly ISearchOrchestrationService _searchOrchestrationService;
    private readonly ISearchResultStore _searchResultStore;
    private readonly IAffiliateOfferSearchOrchestrator _affiliateOfferSearchOrchestrator;
    private readonly IOfferResultStore _offerResultStore;
    private readonly UserContextOptions _userContextOptions;
    private readonly ImageUploadValidator _imageUploadValidator;
    private readonly ILogger<SearchController> _logger;

    public SearchController(
        ISearchOrchestrationService searchOrchestrationService,
        ISearchResultStore searchResultStore,
        IAffiliateOfferSearchOrchestrator affiliateOfferSearchOrchestrator,
        IOfferResultStore offerResultStore,
        IOptions<UserContextOptions> userContextOptions,
        ImageUploadValidator imageUploadValidator,
        ILogger<SearchController> logger)
    {
        _searchOrchestrationService = searchOrchestrationService;
        _searchResultStore = searchResultStore;
        _affiliateOfferSearchOrchestrator = affiliateOfferSearchOrchestrator;
        _offerResultStore = offerResultStore;
        _userContextOptions = userContextOptions.Value;
        _imageUploadValidator = imageUploadValidator;
        _logger = logger;
    }

    [HttpPost("upload")]
    [EnableRateLimiting("upload-limiter")]
    [RequestTimeout("search-upload-timeout")]
    [RequestFormLimits(MultipartBodyLengthLimit = 12 * 1024 * 1024)]
    [RequestSizeLimit(12 * 1024 * 1024)]
    public async Task<IActionResult> UploadAndProcessAsync(
        IFormFile image,
        CancellationToken cancellationToken)
    {
        if (image is null)
        {
            return BadRequest(new { error = "Image file is required." });
        }

        var (isValid, error) = await _imageUploadValidator.ValidateAsync(image, cancellationToken);
        if (!isValid)
        {
            return BadRequest(new { error });
        }

        await using var stream = image.OpenReadStream();
        ImageSearchResult result;
        try
        {
            var context = new SearchUploadContext(
                Request.Headers[DeviceTokenHeaderName].FirstOrDefault(),
                Request.Headers[CountryCodeHeaderName].FirstOrDefault() ?? string.Empty);

            result = await _searchOrchestrationService.ProcessUploadAsync(stream, context, cancellationToken);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Image processing validation failed for file {FileName}.", image.FileName);
            return BadRequest(new { error = ex.Message });
        }

        await _searchResultStore.StoreAsync(result, cancellationToken);

        _logger.LogInformation(
            "Upload processed successfully. RequestId={RequestId}, FileName={FileName}, TagsStatus={TagsStatus}.",
            result.RequestId,
            image.FileName,
            result.TagsStatus);

        return Ok(BuildResponse(result, includeCroppedImage: false));
    }

    [HttpGet("{requestId}/result")]
    public async Task<IActionResult> GetResultAsync(string requestId, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(requestId))
        {
            return BadRequest(new { error = "requestId is required." });
        }

        var result = await _searchResultStore.GetAsync(requestId, cancellationToken);
        if (result is null)
        {
            return NotFound(new { error = "Result not found or expired." });
        }

        return Ok(BuildResponse(result, includeCroppedImage: true));
    }

    [HttpPost("{requestId}/offers/start")]
    [EnableRateLimiting("offers-limiter")]
    public async Task<IActionResult> StartOffersSearchAsync(
        string requestId,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(requestId))
        {
            return BadRequest(new { error = "requestId is required." });
        }

        var countryCode = Request.Headers[CountryCodeHeaderName].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(countryCode))
        {
            countryCode = _userContextOptions.DefaultCountryCode;
        }

        var started = await _affiliateOfferSearchOrchestrator.TryStartSearchAsync(
            requestId,
            countryCode,
            cancellationToken);

        if (!started)
        {
            return BadRequest(new
            {
                error = "Cannot start offers search. Upload image first and ensure tags are available.",
                requestId
            });
        }

        var session = await _offerResultStore.GetSessionAsync(requestId, cancellationToken);

        return Accepted(new
        {
            message = "Affiliate offers search started.",
            requestId,
            countryCode,
            provider = "skimlinks",
            searchLogId = session?.SearchLogId,
            streaming = new
            {
                hubPath = "/hubs/search-offers",
                joinGroupMethod = "JoinSearchGroup",
                leaveGroupMethod = "LeaveSearchGroup",
                events = new[]
                {
                    "SearchStarted",
                    "OfferReceived",
                    "ProviderSearchCompleted",
                    "OffersCatchUp",
                    "SearchCompleted"
                }
            }
        });
    }

    [HttpGet("{requestId}/offers")]
    public async Task<IActionResult> GetOffersAsync(string requestId, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(requestId))
        {
            return BadRequest(new { error = "requestId is required." });
        }

        var session = await _offerResultStore.GetSessionAsync(requestId, cancellationToken);
        if (session is null)
        {
            return NotFound(new { error = "Offers session not found or expired." });
        }

        var ranked = await _offerResultStore.GetRankedResultAsync(requestId, cancellationToken);
        if (ranked is not null)
        {
            return Ok(new
            {
                session.RequestId,
                status = session.Status,
                totalOffers = session.TotalOffers,
                session.SearchLogId,
                session.StartedAt,
                session.CompletedAt,
                session.FailureReason,
                provider = "skimlinks",
                benchmark = ranked.Benchmark,
                originals = ranked.Originals,
                dupes = ranked.Dupes,
                priceMatches = ranked.PriceMatches,
                summary = ranked.Summary,
                offers = ranked.AllOffers
            });
        }

        var offers = await _offerResultStore.GetOffersAsync(requestId, cancellationToken);
        return Ok(new
        {
            session.RequestId,
            status = session.Status,
            totalOffers = session.TotalOffers,
            session.SearchLogId,
            session.StartedAt,
            session.CompletedAt,
            session.FailureReason,
            provider = "skimlinks",
            benchmark = (AffiliateProductOffer?)null,
            originals = Array.Empty<AffiliateProductOffer>(),
            dupes = offers,
            priceMatches = Array.Empty<AffiliateProductOffer>(),
            summary = (OffersSearchSummary?)null,
            offers
        });
    }

    private static object BuildResponse(ImageSearchResult result, bool includeCroppedImage)
    {
        if (includeCroppedImage)
        {
            return new
            {
                result.RequestId,
                result.BoundingBox,
                result.Confidence,
                result.DetectorVersion,
                result.OriginalWidth,
                result.OriginalHeight,
                result.ProcessedWidth,
                result.ProcessedHeight,
                result.ProcessingMilliseconds,
                tags = result.Tags,
                tagsStatus = result.TagsStatus,
                searchLogId = result.SearchLogId,
                geminiModelVersion = result.GeminiModelVersion,
                result.CroppedImageBase64
            };
        }

        return new
        {
            message = "Image processed successfully.",
            result.RequestId,
            result.BoundingBox,
            result.Confidence,
            result.DetectorVersion,
            result.ProcessingMilliseconds,
            tags = result.Tags,
            tagsStatus = result.TagsStatus,
            searchLogId = result.SearchLogId,
            geminiModelVersion = result.GeminiModelVersion
        };
    }
}

