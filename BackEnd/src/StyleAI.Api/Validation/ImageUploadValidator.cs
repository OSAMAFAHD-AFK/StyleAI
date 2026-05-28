using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Api.Validation;

public sealed class ImageUploadValidator
{
    private static readonly byte[] JpegHeader = [0xFF, 0xD8, 0xFF];
    private static readonly byte[] PngHeader = [0x89, 0x50, 0x4E, 0x47];
    private static readonly byte[] WebpRiff = [0x52, 0x49, 0x46, 0x46]; // RIFF
    private static readonly byte[] WebpMarker = [0x57, 0x45, 0x42, 0x50]; // WEBP

    private readonly ImageProcessingOptions _options;

    public ImageUploadValidator(IOptions<ImageProcessingOptions> options)
    {
        _options = options.Value;
    }

    public async Task<(bool IsValid, string? Error)> ValidateAsync(
        IFormFile file,
        CancellationToken cancellationToken = default)
    {
        if (file.Length <= 0)
        {
            return (false, "File is empty.");
        }

        var maxBytes = _options.MaxUploadSizeMb * 1024L * 1024L;
        if (file.Length > maxBytes)
        {
            return (false, $"File exceeds max allowed size of {_options.MaxUploadSizeMb}MB.");
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!_options.AllowedExtensions.Contains(extension))
        {
            return (false, "Unsupported file extension.");
        }

        if (!_options.AllowedContentTypes.Contains(file.ContentType, StringComparer.OrdinalIgnoreCase))
        {
            return (false, "Unsupported content type.");
        }

        await using var stream = file.OpenReadStream();
        var isValidSignature = await IsImageSignatureValidAsync(stream, cancellationToken);
        if (!isValidSignature)
        {
            return (false, "Invalid image signature.");
        }

        return (true, null);
    }

    private static async Task<bool> IsImageSignatureValidAsync(Stream stream, CancellationToken cancellationToken)
    {
        var header = new byte[12];
        var bytesRead = await stream.ReadAsync(header.AsMemory(0, header.Length), cancellationToken);
        stream.Position = 0;

        if (bytesRead < 4)
        {
            return false;
        }

        if (header.Take(3).SequenceEqual(JpegHeader))
        {
            return true;
        }

        if (header.Take(4).SequenceEqual(PngHeader))
        {
            return true;
        }

        if (bytesRead >= 12 &&
            header.Take(4).SequenceEqual(WebpRiff) &&
            header.Skip(8).Take(4).SequenceEqual(WebpMarker))
        {
            return true;
        }

        return false;
    }
}
