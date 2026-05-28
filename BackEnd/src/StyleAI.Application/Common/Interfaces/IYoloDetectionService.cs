using StyleAI.Application.Features.Search.Models;

namespace StyleAI.Application.Common.Interfaces;

public interface IYoloDetectionService
{
    Task<YoloDetectionResult> DetectPrimaryItemAsync(
        float[] chwTensor,
        int modelInputWidth,
        int modelInputHeight,
        int imageWidth,
        int imageHeight,
        CancellationToken cancellationToken = default);
}
