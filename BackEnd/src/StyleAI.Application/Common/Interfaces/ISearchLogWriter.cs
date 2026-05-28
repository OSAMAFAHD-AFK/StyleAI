using StyleAI.Application.Features.Search.Models;
using StyleAI.Domain.Entities;

namespace StyleAI.Application.Common.Interfaces;

public interface ISearchLogWriter
{
    Task<long> WriteAsync(
        User user,
        GarmentTags tags,
        string countryCode,
        string aiModelVersion,
        CancellationToken cancellationToken = default);
}
