namespace StyleAI.Infrastructure.Options;

public sealed class GeminiOptions
{
    public const string SectionName = "Gemini";

    public string ApiKey { get; set; } = string.Empty;

    public string ModelId { get; set; } = "gemini-2.5-flash";

    public string BaseUrl { get; set; } = "https://generativelanguage.googleapis.com/";

    public int TimeoutSeconds { get; set; } = 8;

    public int MaxOutputTokens { get; set; } = 120;

    public float Temperature { get; set; } = 0.1f;

    public int MaxRetryAttempts { get; set; } = 1;
}
