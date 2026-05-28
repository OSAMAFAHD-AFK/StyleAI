namespace StyleAI.Application.Features.Search.Models;

public sealed record YoloDetectionResult(
    BoundingBox BoundingBox,
    float Confidence,
    string DetectorVersion
);
