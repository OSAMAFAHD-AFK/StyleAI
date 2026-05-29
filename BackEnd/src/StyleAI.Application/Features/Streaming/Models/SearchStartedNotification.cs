namespace StyleAI.Application.Features.Streaming.Models;

public sealed record SearchStartedNotification(
    string RequestId,
    string CountryCode,
    string Keywords,
    DateTimeOffset StartedAtUtc);
