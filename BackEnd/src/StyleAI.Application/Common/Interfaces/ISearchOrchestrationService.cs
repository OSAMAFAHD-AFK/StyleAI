using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface ISearchOrchestrationService
{
    Task<ImageSearchResult> ProcessUploadAsync(
        Stream imageStream,
        SearchUploadContext context,
        CancellationToken cancellationToken = default);
}
