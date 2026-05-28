using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface ISearchResultStore
{
    Task StoreAsync(ImageSearchResult result, CancellationToken cancellationToken = default);

    Task<ImageSearchResult?> GetAsync(string requestId, CancellationToken cancellationToken = default);
}
