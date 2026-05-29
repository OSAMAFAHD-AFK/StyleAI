using StyleAI.Application.Features.Monetization.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IThriftCounterService
{
    Task<ThriftCounterSummary> GetSummaryAsync(
        string? deviceToken,
        CancellationToken cancellationToken = default);
}
