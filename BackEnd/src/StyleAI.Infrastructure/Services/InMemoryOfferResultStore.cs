using System.Collections.Concurrent;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class InMemoryOfferResultStore : IOfferResultStore
{
    private readonly ConcurrentDictionary<string, OfferSessionState> _sessions = new();
    private readonly ImageProcessingOptions _options;

    public InMemoryOfferResultStore(IOptions<ImageProcessingOptions> options)
    {
        _options = options.Value;
    }

    public Task<AffiliateSearchSession?> GetSessionAsync(string requestId, CancellationToken cancellationToken = default)
    {
        if (_sessions.TryGetValue(requestId, out var session) && !IsExpired(session))
        {
            return Task.FromResult<AffiliateSearchSession?>(session.ToModel());
        }

        return Task.FromResult<AffiliateSearchSession?>(null);
    }

    public Task<IReadOnlyList<AffiliateProductOffer>> GetOffersAsync(string requestId, CancellationToken cancellationToken = default)
    {
        if (_sessions.TryGetValue(requestId, out var session) && !IsExpired(session))
        {
            lock (session.SyncRoot)
            {
                return Task.FromResult<IReadOnlyList<AffiliateProductOffer>>(session.Offers.ToList());
            }
        }

        return Task.FromResult<IReadOnlyList<AffiliateProductOffer>>([]);
    }

    public Task<RankedOffersResult?> GetRankedResultAsync(string requestId, CancellationToken cancellationToken = default)
    {
        if (_sessions.TryGetValue(requestId, out var session) && !IsExpired(session))
        {
            return Task.FromResult(session.RankedResult);
        }

        return Task.FromResult<RankedOffersResult?>(null);
    }

    public Task InitializeSessionAsync(
        string requestId,
        long? searchLogId = null,
        CancellationToken cancellationToken = default)
    {
        var now = DateTimeOffset.UtcNow;
        _sessions[requestId] = new OfferSessionState(requestId, OffersStatus.Running, now, searchLogId);
        Cleanup(now);
        return Task.CompletedTask;
    }

    public Task AppendOfferAsync(AffiliateProductOffer offer, CancellationToken cancellationToken = default)
    {
        if (_sessions.TryGetValue(offer.RequestId, out var session))
        {
            lock (session.SyncRoot)
            {
                session.Offers.Add(offer);
            }
        }

        return Task.CompletedTask;
    }

    public Task ReplaceOffersAsync(
        string requestId,
        IReadOnlyList<AffiliateProductOffer> offers,
        RankedOffersResult rankedResult,
        CancellationToken cancellationToken = default)
    {
        if (_sessions.TryGetValue(requestId, out var session))
        {
            lock (session.SyncRoot)
            {
                session.Offers.Clear();
                session.Offers.AddRange(offers);
                session.RankedResult = rankedResult;
            }
        }

        return Task.CompletedTask;
    }

    public Task CompleteSessionAsync(
        string requestId,
        string status,
        string? failureReason = null,
        CancellationToken cancellationToken = default)
    {
        if (_sessions.TryGetValue(requestId, out var session))
        {
            session.Status = status;
            session.CompletedAt = DateTimeOffset.UtcNow;
            session.FailureReason = failureReason;
        }

        return Task.CompletedTask;
    }

    private bool IsExpired(OfferSessionState session)
    {
        var expiresAt = session.StartedAt.AddMinutes(_options.ResultStoreTtlMinutes);
        if (DateTimeOffset.UtcNow <= expiresAt)
        {
            return false;
        }

        _sessions.TryRemove(session.RequestId, out _);
        return true;
    }

    private void Cleanup(DateTimeOffset now)
    {
        foreach (var entry in _sessions)
        {
            if (now > entry.Value.StartedAt.AddMinutes(_options.ResultStoreTtlMinutes))
            {
                _sessions.TryRemove(entry.Key, out _);
            }
        }
    }

    private sealed class OfferSessionState
    {
        public OfferSessionState(
            string requestId,
            string status,
            DateTimeOffset startedAt,
            long? searchLogId)
        {
            RequestId = requestId;
            Status = status;
            StartedAt = startedAt;
            SearchLogId = searchLogId;
        }

        public object SyncRoot { get; } = new();
        public string RequestId { get; }
        public string Status { get; set; }
        public DateTimeOffset StartedAt { get; }
        public long? SearchLogId { get; }
        public DateTimeOffset? CompletedAt { get; set; }
        public string? FailureReason { get; set; }
        public RankedOffersResult? RankedResult { get; set; }
        public List<AffiliateProductOffer> Offers { get; } = [];

        public AffiliateSearchSession ToModel()
        {
            lock (SyncRoot)
            {
                return new AffiliateSearchSession(
                    RequestId,
                    Status,
                    Offers.Count,
                    StartedAt,
                    CompletedAt,
                    FailureReason,
                    SearchLogId);
            }
        }
    }
}
