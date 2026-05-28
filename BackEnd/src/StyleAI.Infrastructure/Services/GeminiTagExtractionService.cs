using System.Diagnostics;
using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Infrastructure.Options;
using StyleAI.Infrastructure.Prompts;

namespace StyleAI.Infrastructure.Services;

public sealed class GeminiTagExtractionService : IGeminiTagExtractionService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private static readonly JsonElement TagResponseSchema = JsonSerializer.SerializeToElement(new
    {
        type = "OBJECT",
        properties = new
        {
            category = new { type = "STRING" },
            color = new { type = "STRING" },
            style = new { type = "STRING" }
        },
        required = new[] { "category", "color", "style" }
    });

    private static readonly JsonElement ThinkingConfig = JsonSerializer.SerializeToElement(new
    {
        thinkingBudget = 0
    });

    private readonly HttpClient _httpClient;
    private readonly GeminiOptions _options;
    private readonly ILogger<GeminiTagExtractionService> _logger;

    public GeminiTagExtractionService(
        HttpClient httpClient,
        IOptions<GeminiOptions> options,
        ILogger<GeminiTagExtractionService> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<GeminiTagExtractionResult> ExtractTagsAsync(
        string croppedImageBase64,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ApiKey))
        {
            return Failed("gemini_api_key_missing", 0);
        }

        if (string.IsNullOrWhiteSpace(croppedImageBase64))
        {
            return Failed("cropped_image_missing", 0);
        }

        var stopwatch = Stopwatch.StartNew();
        var attempts = Math.Max(1, _options.MaxRetryAttempts + 1);

        for (var attempt = 1; attempt <= attempts; attempt++)
        {
            try
            {
                using var request = BuildRequest(croppedImageBase64);
                using var response = await _httpClient.SendAsync(request, cancellationToken);

                if (IsTransientFailure(response.StatusCode) && attempt < attempts)
                {
                    _logger.LogWarning(
                        "Gemini transient failure {StatusCode}. Retrying attempt {Attempt}/{Attempts}.",
                        response.StatusCode,
                        attempt,
                        attempts);
                    continue;
                }

                if (!response.IsSuccessStatusCode)
                {
                    var errorBody = await response.Content.ReadAsStringAsync(cancellationToken);
                    _logger.LogWarning(
                        "Gemini request failed with {StatusCode}. Body={Body}",
                        response.StatusCode,
                        Truncate(errorBody, 500));
                    return Failed($"gemini_http_{(int)response.StatusCode}", stopwatch.ElapsedMilliseconds);
                }

                var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);
                var jsonText = ExtractResponseText(responseBody);
                if (string.IsNullOrWhiteSpace(jsonText))
                {
                    _logger.LogWarning(
                        "Gemini response had no text payload. Body={Body}",
                        Truncate(responseBody, 500));
                    return Failed("gemini_empty_response", stopwatch.ElapsedMilliseconds);
                }

                if (!TryParseTags(jsonText, out var tags))
                {
                    _logger.LogWarning("Gemini returned invalid tag JSON: {JsonText}", Truncate(jsonText, 300));
                    return Failed("gemini_invalid_json", stopwatch.ElapsedMilliseconds);
                }

                stopwatch.Stop();
                _logger.LogInformation(
                    "Gemini tags extracted via {ModelId} in {ElapsedMs} ms.",
                    _options.ModelId,
                    stopwatch.ElapsedMilliseconds);

                return new GeminiTagExtractionResult(
                    Success: true,
                    Tags: tags,
                    ModelVersion: _options.ModelId,
                    LatencyMilliseconds: stopwatch.ElapsedMilliseconds,
                    FailureReason: null);
            }
            catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested)
            {
                _logger.LogWarning(ex, "Gemini request timed out on attempt {Attempt}.", attempt);
                if (attempt >= attempts)
                {
                    return Failed("gemini_timeout", stopwatch.ElapsedMilliseconds);
                }
            }
            catch (HttpRequestException ex)
            {
                _logger.LogWarning(ex, "Gemini HTTP error on attempt {Attempt}.", attempt);
                if (attempt >= attempts)
                {
                    return Failed("gemini_http_error", stopwatch.ElapsedMilliseconds);
                }
            }
        }

        return Failed("gemini_unknown_failure", stopwatch.ElapsedMilliseconds);
    }

    private HttpRequestMessage BuildRequest(string croppedImageBase64)
    {
        var endpoint =
            $"v1beta/models/{_options.ModelId}:generateContent?key={Uri.EscapeDataString(_options.ApiKey)}";

        var body = new GeminiGenerateContentRequest(
            SystemInstruction: new GeminiContent(
                Parts:
                [
                    new GeminiPart(Text: GarmentTagPrompt.SystemInstruction)
                ]),
            Contents:
            [
                new GeminiContent(
                    Role: "user",
                    Parts:
                    [
                        new GeminiPart(
                            InlineData: new GeminiInlineData("image/jpeg", croppedImageBase64))
                    ])
            ],
            GenerationConfig: new GeminiGenerationConfig(
                ResponseMimeType: "application/json",
                ResponseSchema: TagResponseSchema,
                ThinkingConfig: ThinkingConfig,
                Temperature: _options.Temperature,
                MaxOutputTokens: _options.MaxOutputTokens));

        var request = new HttpRequestMessage(HttpMethod.Post, endpoint)
        {
            Content = JsonContent.Create(body)
        };

        return request;
    }

    private static bool IsTransientFailure(HttpStatusCode statusCode) =>
        statusCode is HttpStatusCode.TooManyRequests
            or HttpStatusCode.RequestTimeout
            or HttpStatusCode.BadGateway
            or HttpStatusCode.ServiceUnavailable
            or HttpStatusCode.GatewayTimeout;

    private static string? ExtractResponseText(string responseBody)
    {
        if (string.IsNullOrWhiteSpace(responseBody))
        {
            return null;
        }

        try
        {
            using var document = JsonDocument.Parse(responseBody);
            var root = document.RootElement;

            if (root.TryGetProperty("candidates", out var candidates) &&
                candidates.ValueKind == JsonValueKind.Array)
            {
                foreach (var candidate in candidates.EnumerateArray())
                {
                    if (!candidate.TryGetProperty("content", out var content) ||
                        !content.TryGetProperty("parts", out var parts) ||
                        parts.ValueKind != JsonValueKind.Array)
                    {
                        continue;
                    }

                    var textBuilder = new System.Text.StringBuilder();
                    foreach (var part in parts.EnumerateArray())
                    {
                        if (part.TryGetProperty("text", out var textElement) &&
                            textElement.ValueKind == JsonValueKind.String)
                        {
                            textBuilder.Append(textElement.GetString());
                        }
                    }

                    if (textBuilder.Length > 0)
                    {
                        return textBuilder.ToString();
                    }
                }
            }
        }
        catch (JsonException)
        {
            return null;
        }

        return null;
    }

    private static bool TryParseTags(string rawText, out GarmentTags tags)
    {
        tags = null!;
        var jsonText = ExtractJsonObject(rawText);

        try
        {
            var dto = JsonSerializer.Deserialize<GarmentTagsDto>(jsonText, JsonOptions);
            if (dto is null)
            {
                return false;
            }

            var category = NormalizeTagValue(dto.Category);
            var color = NormalizeTagValue(dto.Color);
            var style = NormalizeTagValue(dto.Style);

            if (category is null || color is null || style is null)
            {
                return false;
            }

            tags = new GarmentTags(category, color, style);
            return true;
        }
        catch (JsonException)
        {
            return false;
        }
    }

    private static string ExtractJsonObject(string rawText)
    {
        var trimmed = rawText.Trim();
        if (trimmed.StartsWith("```", StringComparison.Ordinal))
        {
            var firstLineBreak = trimmed.IndexOf('\n');
            if (firstLineBreak >= 0)
            {
                trimmed = trimmed[(firstLineBreak + 1)..];
            }

            var fenceEnd = trimmed.LastIndexOf("```", StringComparison.Ordinal);
            if (fenceEnd >= 0)
            {
                trimmed = trimmed[..fenceEnd];
            }
        }

        var start = trimmed.IndexOf('{');
        var end = trimmed.LastIndexOf('}');
        if (start >= 0 && end > start)
        {
            return trimmed[start..(end + 1)];
        }

        return trimmed;
    }

    private static string? NormalizeTagValue(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        return value.Trim().ToLowerInvariant().Replace(' ', '_');
    }

    private static GeminiTagExtractionResult Failed(string reason, long elapsedMs) =>
        new(
            Success: false,
            Tags: null,
            ModelVersion: null,
            LatencyMilliseconds: elapsedMs,
            FailureReason: reason);

    private static string Truncate(string value, int maxLength) =>
        value.Length <= maxLength ? value : value[..maxLength];

    private sealed record GarmentTagsDto(
        [property: JsonPropertyName("category")] string? Category,
        [property: JsonPropertyName("color")] string? Color,
        [property: JsonPropertyName("style")] string? Style);

    private sealed record GeminiGenerateContentRequest(
        [property: JsonPropertyName("systemInstruction")] GeminiContent? SystemInstruction,
        [property: JsonPropertyName("contents")] GeminiContent[] Contents,
        [property: JsonPropertyName("generationConfig")] GeminiGenerationConfig GenerationConfig);

    private sealed record GeminiContent(
        [property: JsonPropertyName("role")] string? Role = null,
        [property: JsonPropertyName("parts")] GeminiPart[]? Parts = null);

    private sealed record GeminiPart(
        [property: JsonPropertyName("text")] string? Text = null,
        [property: JsonPropertyName("inline_data")] GeminiInlineData? InlineData = null);

    private sealed record GeminiInlineData(
        [property: JsonPropertyName("mime_type")] string MimeType,
        [property: JsonPropertyName("data")] string Data);

    private sealed record GeminiGenerationConfig(
        [property: JsonPropertyName("responseMimeType")] string ResponseMimeType,
        [property: JsonPropertyName("responseSchema")] JsonElement ResponseSchema,
        [property: JsonPropertyName("thinkingConfig")] JsonElement ThinkingConfig,
        [property: JsonPropertyName("temperature")] float Temperature,
        [property: JsonPropertyName("maxOutputTokens")] int MaxOutputTokens);

}
