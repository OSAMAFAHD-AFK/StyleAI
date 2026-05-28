using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Domain.Entities;
using StyleAI.Domain.Enums;
using StyleAI.Infrastructure.Options;
using StyleAI.Infrastructure.Persistence;

namespace StyleAI.Infrastructure.Services;

public sealed class UserContextService : IUserContextService
{
    private readonly AppDbContext _dbContext;
    private readonly UserContextOptions _options;

    public UserContextService(AppDbContext dbContext, IOptions<UserContextOptions> options)
    {
        _dbContext = dbContext;
        _options = options.Value;
    }

    public async Task<User> GetOrCreateUserAsync(
        string? deviceToken,
        CancellationToken cancellationToken = default)
    {
        var normalizedToken = string.IsNullOrWhiteSpace(deviceToken)
            ? _options.DefaultDeviceToken
            : deviceToken.Trim();

        var existingUser = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(user => user.DeviceToken == normalizedToken, cancellationToken);

        if (existingUser is not null)
        {
            return existingUser;
        }

        var now = DateTimeOffset.UtcNow;
        var user = new User
        {
            Id = Guid.NewGuid(),
            DeviceToken = normalizedToken,
            PreferredCountry = _options.DefaultCountryCode,
            PreferredCurrency = "USD",
            Status = UserStatus.Anonymous,
            CreatedAt = now,
            UpdatedAt = now,
            LastSeenAt = now
        };

        _dbContext.Users.Add(user);

        try
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
            return user;
        }
        catch (DbUpdateException)
        {
            _dbContext.Entry(user).State = EntityState.Detached;
            return await _dbContext.Users
                .AsNoTracking()
                .FirstAsync(u => u.DeviceToken == normalizedToken, cancellationToken);
        }
    }
}
