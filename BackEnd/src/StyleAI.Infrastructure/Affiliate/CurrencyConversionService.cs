using Microsoft.Extensions.Options;
using StyleAI.Infrastructure.Options;

namespace StyleAI.Infrastructure.Affiliate;

public sealed class CurrencyConversionService
{
    private readonly NormalizationOptions _options;

    public CurrencyConversionService(IOptions<NormalizationOptions> options)
    {
        _options = options.Value;
    }

    public string ResolveCurrencyForCountry(string countryCode)
    {
        var country = countryCode.Trim().ToUpperInvariant();
        if (_options.CountryCurrencies.TryGetValue(country, out var currency))
        {
            return currency;
        }

        return _options.BaseCurrency;
    }

    public (decimal LocalizedPrice, string LocalizedCurrency) ConvertToCountry(
        decimal price,
        string sourceCurrency,
        string targetCountryCode)
    {
        var targetCurrency = ResolveCurrencyForCountry(targetCountryCode);
        var priceInUsd = ConvertToUsd(price, sourceCurrency);
        var localizedPrice = ConvertFromUsd(priceInUsd, targetCurrency);
        return (Math.Round(localizedPrice, 2), targetCurrency);
    }

    private decimal ConvertToUsd(decimal price, string sourceCurrency)
    {
        var currency = sourceCurrency.Trim().ToUpperInvariant();
        if (currency == "USD")
        {
            return price;
        }

        if (_options.ExchangeRatesFromUsd.TryGetValue(currency, out var rate) && rate > 0)
        {
            return price / rate;
        }

        return price;
    }

    private decimal ConvertFromUsd(decimal priceInUsd, string targetCurrency)
    {
        var currency = targetCurrency.Trim().ToUpperInvariant();
        if (currency == "USD")
        {
            return priceInUsd;
        }

        if (_options.ExchangeRatesFromUsd.TryGetValue(currency, out var rate))
        {
            return priceInUsd * rate;
        }

        return priceInUsd;
    }
}
