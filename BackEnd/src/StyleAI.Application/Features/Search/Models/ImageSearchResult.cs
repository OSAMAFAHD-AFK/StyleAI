namespace StyleAI.Application.Features.Search.Models;

public sealed record ImageSearchResult(
    string RequestId,
    BoundingBox BoundingBox,
    float Confidence,
    string DetectorVersion,
    int OriginalWidth,
    int OriginalHeight,
    int ProcessedWidth,
    int ProcessedHeight,
    long ProcessingMilliseconds,
    string CroppedImageBase64,
    GarmentTags? Tags = null,
    string TagsStatus = TagsStatus.Unavailable,
    long? SearchLogId = null,
    string? GeminiModelVersion = null);
