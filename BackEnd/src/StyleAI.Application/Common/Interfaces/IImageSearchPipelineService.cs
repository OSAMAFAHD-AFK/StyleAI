using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IImageSearchPipelineService
{
    Task<ImageSearchResult> ProcessAsync(Stream imageStream, CancellationToken cancellationToken = default);
}
