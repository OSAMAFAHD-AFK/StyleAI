namespace StyleAI.Application.Features.Search.Models;

public sealed record BoundingBox(
    int X,
    int Y,
    int Width,
    int Height
);
