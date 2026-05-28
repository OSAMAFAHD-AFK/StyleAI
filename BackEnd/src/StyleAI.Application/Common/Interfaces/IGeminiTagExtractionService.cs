using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IGeminiTagExtractionService
{
    Task<GeminiTagExtractionResult> ExtractTagsAsync(
        string croppedImageBase64,
        CancellationToken cancellationToken = default);
}
