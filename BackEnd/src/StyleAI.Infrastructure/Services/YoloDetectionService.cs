using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;
using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Search.Models;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Services;

public sealed class YoloDetectionService : IYoloDetectionService, IDisposable
{
    private readonly ILogger<YoloDetectionService> _logger;
    private readonly YoloOptions _options;
    private readonly InferenceSession? _session;

    public YoloDetectionService(
        IOptions<YoloOptions> options,
        ILogger<YoloDetectionService> logger)
    {
        _options = options.Value;
        _logger = logger;

        var absoluteModelPath = Path.GetFullPath(_options.ModelPath);
        if (!File.Exists(absoluteModelPath))
        {
            _logger.LogWarning(
                "YOLO model not found at {ModelPath}. Fallback detector will be used.",
                absoluteModelPath);
            return;
        }

        try
        {
            _session = new InferenceSession(absoluteModelPath);
            _logger.LogInformation("YOLO model loaded from {ModelPath}.", absoluteModelPath);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to initialize YOLO model. Fallback detector will be used.");
        }
    }

    public Task<YoloDetectionResult> DetectPrimaryItemAsync(
        float[] chwTensor,
        int modelInputWidth,
        int modelInputHeight,
        int imageWidth,
        int imageHeight,
        CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();

        if (_session is null)
        {
            return Task.FromResult(BuildFallback(imageWidth, imageHeight, "fallback-center-crop"));
        }

        try
        {
            var inputName = _session.InputMetadata.Keys.First();
            var inputTensor = new DenseTensor<float>(chwTensor, [1, 3, modelInputHeight, modelInputWidth]);
            var input = NamedOnnxValue.CreateFromTensor(inputName, inputTensor);
            using var results = _session.Run([input]);

            var output = results.First().AsTensor<float>();
            var best = TryExtractBestDetection(output, modelInputWidth, modelInputHeight);
            if (best is null || best.Value.Confidence < _options.ConfidenceThreshold)
            {
                return Task.FromResult(BuildFallback(imageWidth, imageHeight, "fallback-no-high-confidence"));
            }

            var scaleX = imageWidth / (float)modelInputWidth;
            var scaleY = imageHeight / (float)modelInputHeight;

            var box = best.Value.BoundingBox;
            var scaled = new BoundingBox(
                (int)Math.Round(box.X * scaleX),
                (int)Math.Round(box.Y * scaleY),
                Math.Max(1, (int)Math.Round(box.Width * scaleX)),
                Math.Max(1, (int)Math.Round(box.Height * scaleY)));

            return Task.FromResult(new YoloDetectionResult(
                scaled,
                best.Value.Confidence,
                "yolov8-onnx-inference"));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "YOLO inference failed, fallback detector applied.");
            return Task.FromResult(BuildFallback(imageWidth, imageHeight, "fallback-onnx-error"));
        }
    }

    public void Dispose()
    {
        _session?.Dispose();
    }

    private static YoloDetectionResult BuildFallback(int imageWidth, int imageHeight, string version)
    {
        var width = (int)(imageWidth * 0.60);
        var height = (int)(imageHeight * 0.70);
        var x = Math.Max(0, (imageWidth - width) / 2);
        var y = Math.Max(0, (imageHeight - height) / 2);
        return new YoloDetectionResult(new BoundingBox(x, y, width, height), 0.50f, version);
    }

    private static (BoundingBox BoundingBox, float Confidence)? TryExtractBestDetection(
        Tensor<float> tensor,
        int modelInputWidth,
        int modelInputHeight)
    {
        var dims = tensor.Dimensions.ToArray();
        var data = tensor.ToArray();

        if (dims.Length == 3)
        {
            if (dims[1] >= 5 && dims[2] > 0)
            {
                // Common YOLOv8 shape: [1,84,N] (channels-first predictions)
                return ExtractBestFromChannelsFirst(data, dims[1], dims[2], modelInputWidth, modelInputHeight);
            }

            if (dims[2] >= 5 && dims[1] > 0)
            {
                // Alternative shape: [1,N,84]
                return ExtractBestFromRows(data, dims[1], dims[2], modelInputWidth, modelInputHeight);
            }
        }

        return null;
    }

    private static (BoundingBox BoundingBox, float Confidence)? ExtractBestFromChannelsFirst(
        float[] data,
        int channels,
        int rows,
        int modelInputWidth,
        int modelInputHeight)
    {
        float bestConfidence = 0f;
        BoundingBox? bestBox = null;

        for (var i = 0; i < rows; i++)
        {
            var cx = data[i];
            var cy = data[rows + i];
            var w = data[(2 * rows) + i];
            var h = data[(3 * rows) + i];

            var classConfidence = 0f;
            for (var c = 4; c < channels; c++)
            {
                classConfidence = Math.Max(classConfidence, data[(c * rows) + i]);
            }

            if (classConfidence <= bestConfidence)
            {
                continue;
            }

            var x = Math.Clamp(cx - (w / 2f), 0, modelInputWidth - 1);
            var y = Math.Clamp(cy - (h / 2f), 0, modelInputHeight - 1);
            var width = Math.Clamp(w, 1, modelInputWidth - x);
            var height = Math.Clamp(h, 1, modelInputHeight - y);

            bestConfidence = classConfidence;
            bestBox = new BoundingBox((int)x, (int)y, (int)width, (int)height);
        }

        return bestBox is null ? null : (bestBox, bestConfidence);
    }

    private static (BoundingBox BoundingBox, float Confidence)? ExtractBestFromRows(
        float[] data,
        int rows,
        int columns,
        int modelInputWidth,
        int modelInputHeight)
    {
        float bestConfidence = 0f;
        BoundingBox? bestBox = null;

        for (var r = 0; r < rows; r++)
        {
            var offset = r * columns;
            var cx = data[offset];
            var cy = data[offset + 1];
            var w = data[offset + 2];
            var h = data[offset + 3];

            var classConfidence = 0f;
            for (var c = 4; c < columns; c++)
            {
                classConfidence = Math.Max(classConfidence, data[offset + c]);
            }

            if (classConfidence <= bestConfidence)
            {
                continue;
            }

            var x = Math.Clamp(cx - (w / 2f), 0, modelInputWidth - 1);
            var y = Math.Clamp(cy - (h / 2f), 0, modelInputHeight - 1);
            var width = Math.Clamp(w, 1, modelInputWidth - x);
            var height = Math.Clamp(h, 1, modelInputHeight - y);

            bestConfidence = classConfidence;
            bestBox = new BoundingBox((int)x, (int)y, (int)width, (int)height);
        }

        return bestBox is null ? null : (bestBox, bestConfidence);
    }
}
