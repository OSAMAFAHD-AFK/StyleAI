using StyleAI.Application.Common.Interfaces;
using StyleAI.Application.Features.Affiliate.Models;
using StyleAI.Infrastructure.Affiliate;

namespace StyleAI.Infrastructure.Services;

public sealed class ProductNormalizationService : IProductNormalizationService
{
    private readonly ColorNormalizationService _colorNormalizationService;
    private readonly SizeNormalizationService _sizeNormalizationService;
    private readonly CurrencyConversionService _currencyConversionService;
    private readonly MerchantNormalizationService _merchantNormalizationService;

    public ProductNormalizationService(
        ColorNormalizationService colorNormalizationService,
        SizeNormalizationService sizeNormalizationService,
        CurrencyConversionService currencyConversionService,
        MerchantNormalizationService merchantNormalizationService)
    {
        _colorNormalizationService = colorNormalizationService;
        _sizeNormalizationService = sizeNormalizationService;
        _currencyConversionService = currencyConversionService;
        _merchantNormalizationService = merchantNormalizationService;
    }

    public AffiliateProductOffer Normalize(
        RawAffiliateOffer raw,
        string requestId,
        string provider,
        string targetCountryCode,
        string normalizedColor,
        int sequenceNumber)
    {
        var title = raw.Title.Trim();
        var color = _colorNormalizationService.Normalize(raw.Color, normalizedColor);
        var size = _sizeNormalizationService.Normalize(raw.Size, targetCountryCode);
        var merchantName = raw.MerchantName.Trim();
        var merchantSlug = _merchantNormalizationService.NormalizeSlug(merchantName);
        var (localizedPrice, localizedCurrency) = _currencyConversionService.ConvertToCountry(
            raw.Price,
            raw.Currency,
            targetCountryCode);

        return new AffiliateProductOffer(
            OfferId: $"{provider}:{raw.ExternalId}",
            RequestId: requestId,
            Provider: provider,
            Title: title,
            Description: raw.Description?.Trim(),
            MerchantName: merchantName,
            MerchantSlug: merchantSlug,
            ComparisonTitle: title.ToLowerInvariant(),
            ProductUrl: raw.ProductUrl,
            ImageUrl: raw.ImageUrl,
            Price: raw.Price,
            Currency: raw.Currency.ToUpperInvariant(),
            LocalizedPrice: localizedPrice,
            LocalizedCurrency: localizedCurrency,
            NormalizedColor: color,
            NormalizedSize: size,
            SourceCountry: raw.SourceCountry,
            SequenceNumber: sequenceNumber);
    }
}
