using StyleAI.Domain.Enums;

namespace StyleAI.Domain.Entities;

public class User
{
    public Guid Id { get; set; }

    public string DeviceToken { get; set; } = string.Empty;

    public string? Email { get; set; }

    public string PreferredCountry { get; set; } = string.Empty;

    public string PreferredCurrency { get; set; } = string.Empty;

    public decimal TotalSavings { get; set; }

    public UserStatus Status { get; set; } = UserStatus.Anonymous;

    public DateTimeOffset CreatedAt { get; set; }

    public DateTimeOffset UpdatedAt { get; set; }

    public DateTimeOffset? LastSeenAt { get; set; }

    public ICollection<SearchLog> SearchLogs { get; set; } = new List<SearchLog>();

    public ICollection<ClickTracking> ClickTrackings { get; set; } = new List<ClickTracking>();
}
