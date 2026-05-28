namespace StyleAI.Infrastructure.Options;

public sealed class YoloOptions
{
    public const string SectionName = "Yolo";

    public string ModelPath { get; set; } = "Models/yolov8n.onnx";

    public float ConfidenceThreshold { get; set; } = 0.35f;

    public int InputWidth { get; set; } = 640;

    public int InputHeight { get; set; } = 640;
}
