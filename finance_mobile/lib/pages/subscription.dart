import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../popups/add_subscription.dart';
import '../popups/subscription_actions.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../models/subscription_models.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionService _service = SubscriptionService();
  final ApiService _apiService = ApiService();

  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final userIdStr = await _apiService.getUserId();

      if (userIdStr == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        return;
      }

      _userId = int.parse(userIdStr);

      final subscriptions = await _service.getSubscriptions(_userId!);

      if (mounted) {
        setState(() {
          _subscriptions = subscriptions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
              const Text(
                "Abonelikler",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  if (_userId != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AddSubscriptionPopup(
                        userId: _userId!,
                        onSubscriptionAdded: _loadSubscriptions,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20, color: Colors.white),
                label: const Text("Yeni Abonelik", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildWebStatCard(
                              title: "Toplam Aylık Harcama",
                              value: "₺${_calculateTotalExpense().toStringAsFixed(2)}",
                              icon: Icons.paid_outlined,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildWebStatCard(
                              title: "Aktif Abonelik",
                              value: "${_subscriptions.length}",
                              icon: Icons.subscriptions_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildWebStatCard(
                              title: "Yaklaşan Ödemeler",
                              value: _getUpcomingPaymentsCount(),
                              icon: Icons.calendar_today_outlined,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Subscriptions List
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  const Text(
                                    "Tüm Abonelikler",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${_subscriptions.length} abonelik",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            _subscriptions.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(60),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.subscriptions_outlined,
                                          size: 64,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Henüz abonelik eklenmemiş",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Yeni bir abonelik eklemek için üstteki butona tıklayın",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(20),
                                    itemCount: _subscriptions.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      return _buildWebSubscriptionCard(_subscriptions[index]);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // 📱 MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          label: "Islemler",
                          onTap: () => Navigator.pushNamed(context, '/transactions'),
                        ),
                        _navButton(
                          context,
                          icon: Icons.subscriptions_outlined,
                          label: "Abonelikler",
                          isActive: true,
                          onTap: () {},
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
                          onTap: () => Navigator.pushNamed(context, '/currency'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Başlık ve Ekle Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Abonelikler",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_userId != null) {
                            showDialog(
                              context: context,
                              builder: (context) => AddSubscriptionPopup(
                                userId: _userId!,
                                onSubscriptionAdded: _loadSubscriptions,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Abonelik Ekle"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Toplam Aylık Harcama
                  _infoCard(
                    title: "Toplam Aylık Harcama",
                    value: "${_calculateTotalExpense().toStringAsFixed(2)} ₺",
                    icon: Icons.paid_outlined,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),

                  // Yaklaşan Ödemeler
                  _infoCard(
                    title: "Yaklaşan Ödemeler",
                    value: _getUpcomingPaymentsText(),
                    icon: Icons.calendar_today_outlined,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 25),

                  // Tüm Abonelikler
                  const Text(
                    "Tüm Abonelikler",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _subscriptions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Henüz abonelik eklenmemiş.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: _subscriptions.map((sub) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 1,
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SubscriptionActionsPopup(
                                      subscription: sub,
                                      userId: _userId!,
                                      onActionCompleted: _loadSubscriptions,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Icon(
                                        sub.isOverdue
                                            ? Icons.warning_amber_rounded
                                            : Icons.subscriptions_outlined,
                                        color: sub.isOverdue ? Colors.orange : Colors.black54,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sub.subscriptionName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${sub.subscriptionCategory} • ${sub.formattedNextPayment}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: sub.isOverdue ? Colors.orange : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "₺${sub.monthlyFee.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  // WEB STAT CARD
  Widget _buildWebStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // WEB SUBSCRIPTION CARD
  Widget _buildWebSubscriptionCard(Subscription sub) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SubscriptionActionsPopup(
            subscription: sub,
            userId: _userId!,
            onActionCompleted: _loadSubscriptions,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sub.isOverdue ? Colors.orange.withValues(alpha: 0.3) : Colors.grey[200]!,
            width: sub.isOverdue ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sub.isOverdue
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                sub.isOverdue ? Icons.warning_amber_rounded : Icons.subscriptions_outlined,
                color: sub.isOverdue ? Colors.orange : Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.subscriptionName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sub.subscriptionCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        sub.formattedNextPayment,
                        style: TextStyle(
                          fontSize: 13,
                          color: sub.isOverdue ? Colors.orange : Colors.grey[600],
                          fontWeight: sub.isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₺${sub.monthlyFee.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "/ ay",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // MOBILE INFO CARD
  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MOBILE NAV BUTTON
  Widget _navButton(BuildContext context,
      {required IconData icon,
      required String label,
      bool isActive = false,
      required VoidCallback onTap}) {
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

  // HELPERS
  double _calculateTotalExpense() {
    double total = 0;
    for (var sub in _subscriptions) {
      total += sub.monthlyFee;
    }
    return total;
  }

  String _getUpcomingPaymentsText() {
    if (_subscriptions.isEmpty) return "Henüz ödeme bulunmuyor";

    final now = DateTime.now();

    final upcoming = _subscriptions.where((s) {
      try {
        final paymentDate = DateTime.parse(s.nextPaymentDate);
        return paymentDate.isAfter(now);
      } catch (e) {
        return false;
      }
    }).take(3).map((s) => s.subscriptionName).join(", ");

    return upcoming.isEmpty ? "Bu ay kalan ödeme yok" : upcoming;
  }

  String _getUpcomingPaymentsCount() {
    if (_subscriptions.isEmpty) return "0";

    final now = DateTime.now();
    final count = _subscriptions.where((s) {
      try {
        final paymentDate = DateTime.parse(s.nextPaymentDate);
        final daysUntil = paymentDate.difference(now).inDays;
        return daysUntil >= 0 && daysUntil <= 7;
      } catch (e) {
        return false;
      }
    }).length;

    return count.toString();
  }
}