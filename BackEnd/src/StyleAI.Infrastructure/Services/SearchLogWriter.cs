using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Domain.Entities;
using StyleAI.Infrastructure.Persistence;

namespace StyleAI.Infrastructure.Services;

public sealed class SearchLogWriter : ISearchLogWriter
{
    private readonly AppDbContext _dbContext;

    public SearchLogWriter(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<long> WriteAsync(
        User user,
        GarmentTags tags,
        string countryCode,
        string aiModelVersion,
        CancellationToken cancellationToken = default)
    {
        var searchLog = new SearchLog
        {
            UserId = user.Id,
            Category = tags.Category,
            Color = tags.Color,
            StyleAesthetic = tags.Style,
            CountryCode = NormalizeCountryCode(countryCode),
            AiModelVersion = aiModelVersion,
            SearchedAt = DateTimeOffset.UtcNow
        };

        _dbContext.SearchLogs.Add(searchLog);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return searchLog.Id;
    }

    private static string NormalizeCountryCode(string countryCode)
    {
        if (string.IsNullOrWhiteSpace(countryCode))
        {
            return "XX";
        }

        var normalized = countryCode.Trim().ToUpperInvariant();
        return normalized.Length > 2 ? normalized[..2] : normalized;
    }
}
