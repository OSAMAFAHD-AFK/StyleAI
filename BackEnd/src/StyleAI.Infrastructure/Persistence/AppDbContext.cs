using Microsoft.EntityFrameworkCore;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Domain.Entities;

namespace StyleAI.Infrastructure.Persistence;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options), IApplicationDbContext
{
    public DbSet<User> Users => Set<User>();

    public DbSet<SearchLog> SearchLogs => Set<SearchLog>();

    public DbSet<ClickTracking> ClickTrackings => Set<ClickTracking>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
