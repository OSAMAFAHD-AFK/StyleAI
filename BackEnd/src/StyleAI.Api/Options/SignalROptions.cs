namespace StyleAI.Api.Options;

public sealed class SignalROptions
{
    public const string SectionName = "SignalR";

    public string HubPath { get; set; } = "/hubs/search-offers";

    public int KeepAliveIntervalSeconds { get; set; } = 15;

    public int ClientTimeoutSeconds { get; set; } = 60;

    public int HandshakeTimeoutSeconds { get; set; } = 15;

    public int MaximumReceiveMessageSizeKb { get; set; } = 128;

    public string[] CorsOrigins { get; set; } = [];
}
