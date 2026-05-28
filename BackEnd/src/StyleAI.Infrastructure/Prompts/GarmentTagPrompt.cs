namespace StyleAI.Infrastructure.Prompts;

internal static class GarmentTagPrompt
{
    public const string SystemInstruction =
        """
        Classify the single clothing item in the image.
        Output JSON only with keys: category, color, style.
        Use lowercase English snake_case (examples: dress, dark_green, casual).
        Do not include markdown or any text outside JSON.
        """;
}
