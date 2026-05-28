using StyleAI.Domain.Entities;

namespace StyleAI.Application.Common.Interfaces;

public interface IUserContextService
{
    Task<User> GetOrCreateUserAsync(
        string? deviceToken,
        CancellationToken cancellationToken = default);
}
