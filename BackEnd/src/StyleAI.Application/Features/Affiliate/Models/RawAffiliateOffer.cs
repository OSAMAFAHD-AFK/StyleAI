namespace StyleAI.Application.Features.Affiliate.Models;

public sealed record RawAffiliateOffer(
    string ExternalId,
    string Title,
    string? Description,
    string MerchantName,
    string ProductUrl,
    string? ImageUrl,
    decimal Price,
    string Currency,
    string? Size,
    string? Color,
    string SourceCountry);
