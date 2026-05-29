using Microsoft.EntityFrameworkCore;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Monetization.Models;
using StyleAI.Infrastructure.Persistence;

namespace StyleAI.Infrastructure.Services;

public sealed class ThriftCounterService : IThriftCounterService
{
    private readonly AppDbContext _dbContext;
    private readonly IUserContextService _userContextService;

    public ThriftCounterService(AppDbContext dbContext, IUserContextService userContextService)
    {
        _dbContext = dbContext;
        _userContextService = userContextService;
    }

    public async Task<ThriftCounterSummary> GetSummaryAsync(
        string? deviceToken,
        CancellationToken cancellationToken = default)
    {
        var user = await _userContextService.GetOrCreateUserAsync(deviceToken, cancellationToken);

        var clickStats = await _dbContext.ClickTrackings
            .AsNoTracking()
            .Where(click => click.UserId == user.Id)
            .GroupBy(_ => 1)
            .Select(group => new
            {
                TotalClicks = group.Count(),
                ConvertedClicks = group.Count(click => click.IsConverted)
            })
            .FirstOrDefaultAsync(cancellationToken);

        return new ThriftCounterSummary(
            user.Id,
            user.TotalSavings,
            string.IsNullOrWhiteSpace(user.PreferredCurrency) ? "USD" : user.PreferredCurrency,
            clickStats?.TotalClicks ?? 0,
            clickStats?.ConvertedClicks ?? 0);
    }
}
