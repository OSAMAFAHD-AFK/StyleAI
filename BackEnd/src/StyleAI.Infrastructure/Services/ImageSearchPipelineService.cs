using System.Diagnostics;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SkiaSharp;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class ImageSearchPipelineService : IImageSearchPipelineService
{
    private readonly IYoloDetectionService _yoloDetectionService;
    private readonly ILogger<ImageSearchPipelineService> _logger;
    private readonly ImageProcessingOptions _options;
    private readonly YoloOptions _yoloOptions;

    public ImageSearchPipelineService(
        IYoloDetectionService yoloDetectionService,
        IOptions<ImageProcessingOptions> options,
        IOptions<YoloOptions> yoloOptions,
        ILogger<ImageSearchPipelineService> logger)
    {
        _yoloDetectionService = yoloDetectionService;
        _logger = logger;
        _options = options.Value;
        _yoloOptions = yoloOptions.Value;
    }

    public async Task<ImageSearchResult> ProcessAsync(
        Stream imageStream,
        CancellationToken cancellationToken = default)
    {
        var requestId = Guid.NewGuid().ToString("N");
        var stopwatch = Stopwatch.StartNew();

        using var sourceBytesStream = new MemoryStream();
        await imageStream.CopyToAsync(sourceBytesStream, cancellationToken);
        var sourceBytes = sourceBytesStream.ToArray();

        using var sourceBitmap = SKBitmap.Decode(sourceBytes);
        if (sourceBitmap is null)
        {
            throw new InvalidOperationException("Failed to decode uploaded image.");
        }

        var originalWidth = sourceBitmap.Width;
        var originalHeight = sourceBitmap.Height;
        EnsureAllowedDimensions(originalWidth, originalHeight);

        using var processedBitmap = ResizeIfNeeded(sourceBitmap, _options.ResizeMaxDimension);
        var (chwTensor, modelWidth, modelHeight) = BuildModelTensor(
            processedBitmap,
            _yoloOptions.InputWidth,
            _yoloOptions.InputHeight);

        var detection = await _yoloDetectionService.DetectPrimaryItemAsync(
            chwTensor,
            modelWidth,
            modelHeight,
            processedBitmap.Width,
            processedBitmap.Height,
            cancellationToken);

        var cropRectangle = ToCropRectangle(processedBitmap.Width, processedBitmap.Height, detection.BoundingBox);

        using var croppedBitmap = new SKBitmap(cropRectangle.Width, cropRectangle.Height, processedBitmap.ColorType, processedBitmap.AlphaType);
        using (var canvas = new SKCanvas(croppedBitmap))
        {
            var destinationRectangle = new SKRect(0, 0, cropRectangle.Width, cropRectangle.Height);
            var sourceRectangle = new SKRect(cropRectangle.Left, cropRectangle.Top, cropRectangle.Right, cropRectangle.Bottom);
            canvas.DrawBitmap(processedBitmap, sourceRectangle, destinationRectangle);
        }

        using var croppedImage = SKImage.FromBitmap(croppedBitmap);
        using var encoded = croppedImage.Encode(SKEncodedImageFormat.Jpeg, 85);
        var croppedBytes = encoded.ToArray();

        var result = new ImageSearchResult(
            requestId,
            new BoundingBox(cropRectangle.Left, cropRectangle.Top, cropRectangle.Width, cropRectangle.Height),
            detection.Confidence,
            detection.DetectorVersion,
            originalWidth,
            originalHeight,
            processedBitmap.Width,
            processedBitmap.Height,
            stopwatch.ElapsedMilliseconds,
            Convert.ToBase64String(croppedBytes));

        _logger.LogInformation(
            "Search image pipeline completed for {RequestId} in {ElapsedMs} ms. Detector={DetectorVersion}, Confidence={Confidence}.",
            result.RequestId,
            result.ProcessingMilliseconds,
            result.DetectorVersion,
            result.Confidence);

        return result;
    }

    private void EnsureAllowedDimensions(int width, int height)
    {
        if (width <= _options.MaxImageWidth && height <= _options.MaxImageHeight)
        {
            return;
        }

        throw new InvalidOperationException(
            $"Image dimensions exceed allowed maximum {_options.MaxImageWidth}x{_options.MaxImageHeight}.");
    }

    private static SKBitmap ResizeIfNeeded(SKBitmap sourceBitmap, int maxDimension)
    {
        var maxCurrentDimension = Math.Max(sourceBitmap.Width, sourceBitmap.Height);
        if (maxCurrentDimension <= maxDimension)
        {
            return sourceBitmap.Copy();
        }

        var scale = (float)maxDimension / maxCurrentDimension;
        var width = Math.Max(1, (int)Math.Round(sourceBitmap.Width * scale));
        var height = Math.Max(1, (int)Math.Round(sourceBitmap.Height * scale));

        var resized = sourceBitmap.Resize(
            new SKImageInfo(width, height, sourceBitmap.ColorType, sourceBitmap.AlphaType),
            SKSamplingOptions.Default);

        if (resized is null)
        {
            throw new InvalidOperationException("Failed to resize uploaded image.");
        }

        return resized;
    }

    private static SKRectI ToCropRectangle(int imageWidth, int imageHeight, BoundingBox box)
    {
        var x = Math.Clamp(box.X, 0, imageWidth - 1);
        var y = Math.Clamp(box.Y, 0, imageHeight - 1);
        var width = Math.Clamp(box.Width, 1, imageWidth - x);
        var height = Math.Clamp(box.Height, 1, imageHeight - y);

        return new SKRectI(x, y, x + width, y + height);
    }

    private static (float[] Tensor, int ModelWidth, int ModelHeight) BuildModelTensor(
        SKBitmap bitmap,
        int modelWidth,
        int modelHeight)
    {
        using var resized = bitmap.Resize(
            new SKImageInfo(modelWidth, modelHeight, SKColorType.Rgba8888, SKAlphaType.Premul),
            SKSamplingOptions.Default);

        if (resized is null)
        {
            throw new InvalidOperationException("Failed to prepare image tensor for YOLO.");
        }

        var tensor = new float[1 * 3 * modelWidth * modelHeight];
        var channelSize = modelWidth * modelHeight;

        for (var y = 0; y < modelHeight; y++)
        {
            for (var x = 0; x < modelWidth; x++)
            {
                var color = resized.GetPixel(x, y);
                var index = y * modelWidth + x;
                tensor[index] = color.Red / 255f;
                tensor[channelSize + index] = color.Green / 255f;
                tensor[(2 * channelSize) + index] = color.Blue / 255f;
            }
        }

        return (tensor, modelWidth, modelHeight);
    }
}
