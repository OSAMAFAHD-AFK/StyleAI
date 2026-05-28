namespace StyleAI.Infrastructure.Options;

public sealed class ImageProcessingOptions
{
    public const string SectionName = "ImageProcessing";

    public int MaxUploadSizeMb { get; set; } = 12;

    public int MaxImageWidth { get; set; } = 4096;

    public int MaxImageHeight { get; set; } = 4096;

    public int ResizeMaxDimension { get; set; } = 1280;

    public int RequestTimeoutSeconds { get; set; } = 8;

    public int RateLimitPerMinute { get; set; } = 30;

    public int ResultStoreTtlMinutes { get; set; } = 30;

    public int ResultStoreMaxItems { get; set; } = 5000;

    public string[] AllowedExtensions { get; set; } = [".jpg", ".jpeg", ".png", ".webp"];

    public string[] AllowedContentTypes { get; set; } =
    [
        "image/jpeg",
        "image/png",
        "image/webp"
    ];
}
