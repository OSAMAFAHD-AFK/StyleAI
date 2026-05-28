using Microsoft.EntityFrameworkCore;
using StyleAI.Domain.Entities;

namespace StyleAI.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<User> Users { get; }

    DbSet<SearchLog> SearchLogs { get; }

    DbSet<ClickTracking> ClickTrackings { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
