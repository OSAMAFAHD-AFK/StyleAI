namespace StyleAI.Infrastructure.Options;

public sealed class UserContextOptions
{
    public const string SectionName = "UserContext";

    public string DefaultDeviceToken { get; set; } = "styleai-anonymous-device";

    public string DefaultCountryCode { get; set; } = "SA";
}
