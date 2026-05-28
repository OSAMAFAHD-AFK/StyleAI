using System.Collections.Concurrent;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class InMemorySearchResultStore : ISearchResultStore
{
    private readonly ConcurrentDictionary<string, StoredResult> _results = new();
    private readonly ImageProcessingOptions _options;

    public InMemorySearchResultStore(IOptions<ImageProcessingOptions> options)
    {
        _options = options.Value;
    }

    public Task StoreAsync(ImageSearchResult result, CancellationToken cancellationToken = default)
    {
        var now = DateTimeOffset.UtcNow;
        _results[result.RequestId] = new StoredResult(result, now);
        Cleanup(now);
        return Task.CompletedTask;
    }

    public Task<ImageSearchResult?> GetAsync(string requestId, CancellationToken cancellationToken = default)
    {
        if (_results.TryGetValue(requestId, out var stored))
        {
            var expiresAt = stored.CreatedAt.AddMinutes(_options.ResultStoreTtlMinutes);
            if (DateTimeOffset.UtcNow <= expiresAt)
            {
                return Task.FromResult<ImageSearchResult?>(stored.Result);
            }

            _results.TryRemove(requestId, out _);
        }

        return Task.FromResult<ImageSearchResult?>(null);
    }

    private void Cleanup(DateTimeOffset now)
    {
        foreach (var entry in _results)
        {
            if (now > entry.Value.CreatedAt.AddMinutes(_options.ResultStoreTtlMinutes))
            {
                _results.TryRemove(entry.Key, out _);
            }
        }

        if (_results.Count <= _options.ResultStoreMaxItems)
        {
            return;
        }

        var oldestKeys = _results
            .OrderBy(item => item.Value.CreatedAt)
            .Take(_results.Count - _options.ResultStoreMaxItems)
            .Select(item => item.Key)
            .ToList();

        foreach (var key in oldestKeys)
        {
            _results.TryRemove(key, out _);
        }
    }

    private sealed record StoredResult(ImageSearchResult Result, DateTimeOffset CreatedAt);
}
