namespace StyleAI.Application.Features.Search.Models;

public sealed record GeminiTagExtractionResult(
    bool Success,
    GarmentTags? Tags,
    string? ModelVersion,
    long LatencyMilliseconds,
    string? FailureReason);
