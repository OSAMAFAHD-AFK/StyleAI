using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Http.Timeouts;
using StyleAI.Api.Validation;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Api.Controllers;

[ApiController]
[Route("api/search")]
public class SearchController : ControllerBase
{
    private const string DeviceTokenHeaderName = "X-Device-Token";
    private const string CountryCodeHeaderName = "X-Country-Code";

    private readonly ISearchOrchestrationService _searchOrchestrationService;
    private readonly ISearchResultStore _searchResultStore;
    private readonly ImageUploadValidator _imageUploadValidator;
    private readonly ILogger<SearchController> _logger;

    public SearchController(
        ISearchOrchestrationService searchOrchestrationService,
        ISearchResultStore searchResultStore,
        ImageUploadValidator imageUploadValidator,
        ILogger<SearchController> logger)
    {
        _searchOrchestrationService = searchOrchestrationService;
        _searchResultStore = searchResultStore;
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
