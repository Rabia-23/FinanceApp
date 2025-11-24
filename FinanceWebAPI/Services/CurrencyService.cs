using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using FinanceWebAPI.DTOs;

namespace FinanceWebAPI.Services
{
    public class CurrencyService
    {
        private readonly HttpClient _httpClient;

        public CurrencyService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<CurrencyDto> GetLatestCurrenciesAsync()
        {
            var url = "https://api.exchangerate.host/latest?base=TRY"; // TRY bazlı
            var response = await _httpClient.GetAsync(url);

            if (!response.IsSuccessStatusCode)
                throw new System.Exception("Failed to load currencies");

            var content = await response.Content.ReadAsStringAsync();
            using var jsonDoc = JsonDocument.Parse(content);
            var rates = jsonDoc.RootElement.GetProperty("rates");

            // Dövizler
            decimal usd = 1 / rates.GetProperty("USD").GetDecimal();
            decimal eur = 1 / rates.GetProperty("EUR").GetDecimal();
            decimal gbp = 1 / rates.GetProperty("GBP").GetDecimal();
            decimal chf = 1 / rates.GetProperty("CHF").GetDecimal();

            // Altın fiyatları (XAU = ons altın)
            decimal xau = 1 / rates.GetProperty("XAU").GetDecimal();
            decimal goldGram = xau / 31.10m; // gram altın
            decimal quarterGold = goldGram * 7.96m; // çeyrek altın yaklaşık
            decimal goldOunce = xau; // ons

            var lastUpdate = jsonDoc.RootElement.GetProperty("date").GetString() ?? "";

            return new CurrencyDto
            {
                USD = usd,
                EUR = eur,
                GBP = gbp,
                CHF = chf,
                GoldGram = goldGram,
                QuarterGold = quarterGold,
                GoldOunce = goldOunce,
                LastUpdate = lastUpdate
            };
        }
    }
}
