using StyleAI.Domain.Enums;

namespace StyleAI.Domain.Entities;

public class SearchLog
{
    public long Id { get; set; }

    public Guid UserId { get; set; }

    public string Category { get; set; } = string.Empty;

    public string Color { get; set; } = string.Empty;

    public string StyleAesthetic { get; set; } = string.Empty;

    public string? DetectedBrand { get; set; }

    public GenderType Gender { get; set; } = GenderType.Unknown;

    public string CountryCode { get; set; } = string.Empty;

    public string? CroppedImageUrl { get; set; }

    public decimal? EstimatedReferencePrice { get; set; }

    public string? ReferenceCurrency { get; set; }

    public string? AiModelVersion { get; set; }

    public Guid? SessionId { get; set; }

    public DateTimeOffset SearchedAt { get; set; }

    public User User { get; set; } = null!;

    public ICollection<ClickTracking> ClickTrackings { get; set; } = new List<ClickTracking>();
}
