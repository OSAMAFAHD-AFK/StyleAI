namespace StyleAI.Domain.Entities;

public class ClickTracking
{
    public long Id { get; set; }

    public Guid UserId { get; set; }

    public long SearchLogId { get; set; }

    public Guid AffiliateTrackingId { get; set; }

    public string TargetMerchant { get; set; } = string.Empty;

    public string? TargetProductUrl { get; set; }

    public string? TargetProductImageUrl { get; set; }

    public decimal OriginalPrice { get; set; }

    public decimal DupePrice { get; set; }

    public decimal SavedAmount { get; set; }

    public string Currency { get; set; } = string.Empty;

    public bool IsConverted { get; set; }

    public decimal? CommissionAmount { get; set; }

    public DateTimeOffset ClickedAt { get; set; }

    public DateTimeOffset? ConvertedAt { get; set; }

    public User User { get; set; } = null!;

    public SearchLog SearchLog { get; set; } = null!;
}
