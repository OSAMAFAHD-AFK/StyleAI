using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class SearchOrchestrationService : ISearchOrchestrationService
{
    private readonly IImageSearchPipelineService _imageSearchPipelineService;
    private readonly IGeminiTagExtractionService _geminiTagExtractionService;
    private readonly IUserContextService _userContextService;
    private readonly ISearchLogWriter _searchLogWriter;
    private readonly ILogger<SearchOrchestrationService> _logger;
    private readonly UserContextOptions _userContextOptions;

    public SearchOrchestrationService(
        IImageSearchPipelineService imageSearchPipelineService,
        IGeminiTagExtractionService geminiTagExtractionService,
        IUserContextService userContextService,
        ISearchLogWriter searchLogWriter,
        IOptions<UserContextOptions> userContextOptions,
        ILogger<SearchOrchestrationService> logger)
    {
        _imageSearchPipelineService = imageSearchPipelineService;
        _geminiTagExtractionService = geminiTagExtractionService;
        _userContextService = userContextService;
        _searchLogWriter = searchLogWriter;
        _userContextOptions = userContextOptions.Value;
        _logger = logger;
    }

    public async Task<ImageSearchResult> ProcessUploadAsync(
        Stream imageStream,
        SearchUploadContext context,
        CancellationToken cancellationToken = default)
    {
        var visionResult = await _imageSearchPipelineService.ProcessAsync(imageStream, cancellationToken);

        var geminiResult = await _geminiTagExtractionService.ExtractTagsAsync(
            visionResult.CroppedImageBase64,
            cancellationToken);

        if (!geminiResult.Success || geminiResult.Tags is null)
        {
            _logger.LogWarning(
                "Gemini tag extraction failed for RequestId={RequestId}. Reason={Reason}. Returning YOLO-only result.",
                visionResult.RequestId,
                geminiResult.FailureReason ?? "unknown");

            return visionResult with
            {
                Tags = null,
                TagsStatus = TagsStatus.GeminiFailed,
                SearchLogId = null,
                GeminiModelVersion = geminiResult.ModelVersion
            };
        }

        long? searchLogId = null;
        try
        {
            var countryCode = string.IsNullOrWhiteSpace(context.CountryCode)
                ? _userContextOptions.DefaultCountryCode
                : context.CountryCode;

            var user = await _userContextService.GetOrCreateUserAsync(context.DeviceToken, cancellationToken);
            searchLogId = await _searchLogWriter.WriteAsync(
                user,
                geminiResult.Tags,
                countryCode,
                geminiResult.ModelVersion ?? "gemini",
                cancellationToken);

            _logger.LogInformation(
                "SearchLog persisted. RequestId={RequestId}, SearchLogId={SearchLogId}, Category={Category}.",
                visionResult.RequestId,
                searchLogId,
                geminiResult.Tags.Category);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to persist SearchLog for RequestId={RequestId}. Continuing with tags in response.",
                visionResult.RequestId);
        }

        return visionResult with
        {
            Tags = geminiResult.Tags,
            TagsStatus = TagsStatus.Available,
            SearchLogId = searchLogId,
            GeminiModelVersion = geminiResult.ModelVersion
        };
    }
}
