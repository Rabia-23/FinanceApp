import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lucide_icons/lucide_icons.dart';
import '../services/currency_service.dart';
import '../services/user_service.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final CurrencyService _currencyService = CurrencyService();
  final ApiService _apiService = ApiService();

  double usd = 0;
  double eur = 0;
  double gbp = 0;
  double chf = 0;
  double jpy = 0;
  double krw = 0;
  String lastUpdate = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final data = await _currencyService.getCurrencies();
      if (mounted) {
        setState(() {
          usd = data["USD"] ?? 0;
          eur = data["EUR"] ?? 0;
          gbp = data["GBP"] ?? 0;
          chf = data["CHF"] ?? 0;
          jpy = data["JPY"] ?? 0;
          krw = data["KRW"] ?? 0;
          lastUpdate = data["lastUpdate"] ?? "";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _logout() async {
    await _apiService.deleteToken();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isWeb ? _buildWebContent() : _buildMobileLayout(),
    );
  }

  // 🌐 WEB CONTENT (Sidebar yok, sadece içerik)
  Widget _buildWebContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Canlı Döviz Kurları",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        lastUpdate.isNotEmpty && lastUpdate.length >= 16
                            ? "Son güncelleme: ${lastUpdate.substring(0, 16)}"
                            : "Yükleniyor...",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _fetchCurrencies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                label: const Text("Yenile", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchCurrencies,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Grid Layout
                        _buildWebCurrencyGrid(),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // 📱 MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCurrencies,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ÜST BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Colors.deepPurple),
                            SizedBox(width: 6),
                            Text(
                              "Finans Takip",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_outlined, size: 16),
                          label: const Text("Çıkış"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // NAV BAR
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _navButton(
                            context,
                            icon: Icons.home_outlined,
                            label: "Ana Sayfa",
                            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                          ),
                          _navButton(
                            context,
                            icon: Icons.receipt_long_outlined,
                            label: "İşlemler",
                            onTap: () => Navigator.pushNamed(context, '/transactions'),
                          ),
                          _navButton(
                            context,
                            icon: Icons.subscriptions_outlined,
                            label: "Abonelikler",
                            onTap: () => Navigator.pushNamed(context, '/subscriptions'),
                          ),
                          _navButton(
                            context,
                            icon: Icons.flag_outlined,
                            label: "Hedefler",
                            onTap: () => Navigator.pushNamed(context, '/goals'),
                          ),
                          _navButton(
                            context,
                            icon: Icons.monetization_on_outlined,
                            label: "Currency",
                            isActive: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // BAŞLIK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Canlı Kurlar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              lastUpdate.isNotEmpty && lastUpdate.length >= 16
                                  ? lastUpdate.substring(0, 16)
                                  : "",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: _fetchCurrencies,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // KARTLAR (Mobile)
                    _buildMobileCurrencyList(),
                  ],
                ),
              ),
            ),
    );
  }

  // WEB GRID LAYOUT (3 columns)
  Widget _buildWebCurrencyGrid() {
    final currencies = [
      {'icon': LucideIcons.dollarSign, 'name': 'USD', 'fullName': 'Amerikan Doları', 'rate': usd, 'color': Colors.green},
      {'icon': LucideIcons.euro, 'name': 'EUR', 'fullName': 'Euro', 'rate': eur, 'color': Colors.blue},
      {'icon': LucideIcons.poundSterling, 'name': 'GBP', 'fullName': 'İngiliz Sterlini', 'rate': gbp, 'color': Colors.purple},
      {'icon': LucideIcons.coins, 'name': 'CHF', 'fullName': 'İsviçre Frangı', 'rate': chf, 'color': Colors.red},
      {'icon': LucideIcons.coins, 'name': 'JPY', 'fullName': 'Japon Yeni', 'rate': jpy, 'color': Colors.orange},
      {'icon': LucideIcons.coins, 'name': 'KRW', 'fullName': 'Güney Kore Wonu', 'rate': krw, 'color': Colors.teal},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive columns: 3 for large, 2 for medium
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.2,
          ),
          itemCount: currencies.length,
          itemBuilder: (context, index) {
            final currency = currencies[index];
            return _buildWebCurrencyCard(
              icon: currency['icon'] as IconData,
              code: currency['name'] as String,
              fullName: currency['fullName'] as String,
              rate: currency['rate'] as double,
              color: currency['color'] as Color,
            );
          },
        );
      },
    );
  }

  // WEB CURRENCY CARD
  Widget _buildWebCurrencyCard({
    required IconData icon,
    required String code,
    required String fullName,
    required double rate,
    required Color color,
  }) {
    final decimals = (code == 'JPY' || code == 'KRW') ? 4 : 2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "₺${rate.toStringAsFixed(decimals)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      "TRY",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MOBILE CURRENCY LIST
  Widget _buildMobileCurrencyList() {
    return Column(
      children: [
        _currencyCard(
          icon: LucideIcons.dollarSign,
          name: "USD (Dolar)",
          rate: "₺${usd.toStringAsFixed(2)}",
          color: Colors.green,
        ),
        _currencyCard(
          icon: LucideIcons.euro,
          name: "EUR (Euro)",
          rate: "₺${eur.toStringAsFixed(2)}",
          color: Colors.blue,
        ),
        _currencyCard(
          icon: LucideIcons.poundSterling,
          name: "GBP (Sterlin)",
          rate: "₺${gbp.toStringAsFixed(2)}",
          color: Colors.purple,
        ),
        _currencyCard(
          icon: LucideIcons.coins,
          name: "CHF (Frank)",
          rate: "₺${chf.toStringAsFixed(2)}",
          color: Colors.red,
        ),
        _currencyCard(
          icon: LucideIcons.coins,
          name: "JPY (Yen)",
          rate: "₺${jpy.toStringAsFixed(4)}",
          color: Colors.orange,
        ),
        _currencyCard(
          icon: LucideIcons.coins,
          name: "KRW (Won)",
          rate: "₺${krw.toStringAsFixed(4)}",
          color: Colors.teal,
        ),
      ],
    );
  }

  // MOBILE CURRENCY CARD
  Widget _currencyCard({
    required IconData icon,
    required String name,
    required String rate,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            rate,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // MOBILE NAV BUTTON
  Widget _navButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}