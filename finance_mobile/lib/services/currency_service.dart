import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // ✅ Ücretsiz API (günde 1500 istek)
  static const String apiUrl = "https://api.exchangerate-api.com/v4/latest/TRY";

  Future<Map<String, dynamic>> getCurrencies() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        // TRY bazlı olduğu için ters çeviriyoruz (1 USD = X TRY)
        double usd = 1 / (rates['USD'] ?? 1);
        double eur = 1 / (rates['EUR'] ?? 1);
        double gbp = 1 / (rates['GBP'] ?? 1);
        double chf = 1 / (rates['CHF'] ?? 1);
        double jpy = 1 / (rates['JPY'] ?? 1);
        double krw = 1 / (rates['KRW'] ?? 1);

        return {
          "USD": usd,
          "EUR": eur,
          "GBP": gbp,
          "CHF": chf,
          "JPY": jpy,
          "KRW": krw,
          "GoldGram": 0.0, // Altın için ayrı API gerekir
          "QuarterGold": 0.0,
          "GoldOunce": 0.0,
          "lastUpdate": DateTime.now().toString().substring(0, 16),
        };
      } else {
        throw Exception("Kur bilgisi alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("API hatası: $e");
    }
  }

  // ✅ Dönüştürme fonksiyonu (opsiyonel)
  Future<double> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final data = await getCurrencies();
    
    if (from == "TRY") {
      return amount / data[to];
    } else if (to == "TRY") {
      return amount * data[from];
    } else {
      // Örn: USD -> EUR
      double tryAmount = amount * data[from];
      return tryAmount / data[to];
    }
  }
}