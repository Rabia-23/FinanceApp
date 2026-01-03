import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../popups/add_transaction.dart';
import '../popups/add_account.dart';
import '../popups/show_budget.dart';
import '../popups/add_budget.dart';
import '../popups/budget_actions.dart';

import '../widgets/graph.dart';
import '../services/home_service.dart';
import '../services/user_service.dart';
import '../models/home_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService _service = HomeService();
  final ApiService _apiService = ApiService();
  Future<HomeData>? _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  void _loadHomeData() async {
    String? token = await _apiService.getToken();

    if (token != null) {
      setState(() {
        _homeDataFuture = _service.getHomeData(token);
      });
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  void _logout() async {
    await _apiService.deleteToken();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  // Hesap silme
  Future<void> _deleteAccount(Account account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabı Sil"),
        content: Text("'${account.accountName}' hesabını silmek istediğinize emin misiniz?\n\nBu hesaba bağlı tüm işlemler de silinecektir."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteAccount(account.accountId);
        _loadHomeData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Hesap silindi")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: (_homeDataFuture == null || isWeb)
          ? null
          : FutureBuilder<HomeData>(
              future: _homeDataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final homeData = snapshot.data!;
                return FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddTransactionPopup(
                        userId: homeData.userId.toString(),
                        onTransactionAdded: () {
                          _loadHomeData();
                        },
                      ),
                    );
                  },
                  backgroundColor: Colors.black87,
                  child: const Icon(Icons.add, color: Colors.white),
                );
              },
            ),
      body: FutureBuilder<HomeData>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Veri bulunamadı'));
          }

          final homeData = snapshot.data!;

          return isWeb ? _buildWebContent(homeData) : _buildMobileLayout(homeData);
        },
      ),
    );
  }

  // ============ ICERIK ============
  Widget _buildWebContent(HomeData homeData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hoş geldiniz!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddTransactionPopup(
                      userId: homeData.userId.toString(),
                      onTransactionAdded: _loadHomeData,
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("İşlem Ekle", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Accounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Banka Hesapları",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Hesap Ekle"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddAccountPopup(
                      userId: homeData.userId.toString(),
                      onAccountAdded: _loadHomeData,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildBankCardsGrid(homeData.accounts),
          const SizedBox(height: 32),

          // Net Worth + Graph
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildNetWorthCard(homeData.netWorth),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: GraphCard(
                  chartData: homeData.chartData,
                  transactions: homeData.lastTransactions,
                  netWorth: homeData.netWorth,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transactions + Budgets
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildTransactionListWeb(homeData.lastTransactions),
              ),
              const SizedBox(width: 20),

              Expanded(
                flex: 1,
                child: _buildBudgetsColumnWeb(homeData.budgets, homeData.userId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankCardsGrid(List<Account> accounts) {
    if (accounts.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text("Henüz hesap bulunmuyor", style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: accounts.length,
          itemBuilder: (context, index) => _buildBankCardWeb(accounts[index]),
        );
      },
    );
  }

  Widget _buildBankCardWeb(Account account) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onLongPress: () => _deleteAccount(account),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, color: Colors.deepPurple, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        account.accountName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currencyFormat.format(account.accountBalance),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionListWeb(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const SizedBox(
          height: 500,
          child: Center(child: Text("Henüz işlem bulunmuyor", style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    final sortedTx = List<Transaction>.from(transactions);
    sortedTx.sort((a, b) {
      final dateA = _parseDateTime(a.transactionDate, a.transactionTime);
      final dateB = _parseDateTime(b.transactionDate, b.transactionTime);
      return dateB.compareTo(dateA);
    });

    final Map<String, List<Transaction>> grouped = {};
    for (final tx in sortedTx) {
      final dateKey = _formatDateKey(tx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Son İşlemler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 500,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ...entry.value.map((tx) => _buildTransactionItem(tx)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsColumnWeb(List<Budget> budgets, int userId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Bütçeler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 500,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...budgets.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBudgetCard(context, budget: b, userId: userId),
                    )),
                _buildNewBudgetCardWeb(context, userId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewBudgetCardWeb(BuildContext context, int userId) {
    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (context) => AddBudgetPopup(userId: userId, onBudgetAdded: _loadHomeData)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 40, color: Colors.black54),
                  SizedBox(height: 8),
                  Text("New Budget +",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ MOBILE LAYOUT ============
  Widget _buildMobileLayout(HomeData homeData) {
    return SafeArea(
      child: SingleChildScrollView(
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
                  _navButton(context,
                      icon: Icons.home_outlined,
                      label: "Ana Sayfa",
                      isActive: true,
                      onTap: () => Navigator.pushReplacementNamed(context, '/home')),
                  _navButton(context,
                      icon: Icons.receipt_long_outlined,
                      label: "Islemler",
                      onTap: () => Navigator.pushNamed(context, '/transactions')),
                  _navButton(context,
                      icon: Icons.subscriptions_outlined,
                      label: "Abonelikler",
                      onTap: () => Navigator.pushNamed(context, '/subscriptions')),
                  _navButton(context,
                      icon: Icons.flag_outlined,
                      label: "Hedefler",
                      onTap: () => Navigator.pushNamed(context, '/goals')),
                  _navButton(context,
                      icon: Icons.monetization_on_outlined,
                      label: "Currency",
                      onTap: () => Navigator.pushNamed(context, '/currency')),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Hoş geldiniz, ${homeData.userName}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),

            // BANKA HESAPLARI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Banka Hesapları",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Hesap Ekle"),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black87, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddAccountPopup(
                        userId: homeData.userId.toString(),
                        onAccountAdded: _loadHomeData,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...homeData.accounts.map((acc) => _buildBankCard(acc)),

            const SizedBox(height: 16),
            // BÜTÇE KARTLARI
            const Text(
              "Bütçeler",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...homeData.budgets.map((b) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildBudgetCard(context, budget: b, userId: homeData.userId),
                      )),
                  _buildNewBudgetCard(context, homeData.userId),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildNetWorthCard(homeData.netWorth),
            const SizedBox(height: 16),
            GraphCard(
              chartData: homeData.chartData,
              transactions: homeData.lastTransactions,
              netWorth: homeData.netWorth,
            ),
            const SizedBox(height: 16),
            _buildTransactionList(homeData.lastTransactions),
          ],
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context,
      {required IconData icon, required String label, bool isActive = false, required VoidCallback onTap}) {
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
              Text(label,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard(Account account) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return GestureDetector(
      onLongPress: () => _deleteAccount(account),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.account_balance_outlined, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(account.accountName, style: const TextStyle(fontSize: 16)),
              ]),
              Text(currencyFormat.format(account.accountBalance),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, {required Budget budget, required int userId}) {
    final double percent = (budget.spent / budget.total).clamp(0.0, 1.0);
    final percentText = (percent * 100).toStringAsFixed(0);

    Color progressColor;
    if (percent < 0.5) {
      progressColor = Colors.green;
    } else if (percent < 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    final now = DateTime.now();
    final endDate = DateTime.parse(budget.endDate);
    final daysRemaining = endDate.difference(now).inDays;
    final weeksRemaining = (daysRemaining / 7).ceil();

    String remainingText = "";
    if (budget.periodType == "Weekly" || budget.periodType == "Monthly") {
      if (daysRemaining > 0) {
        remainingText = "$daysRemaining gün kaldı";
      } else if (daysRemaining == 0) {
        remainingText = "Bugün bitiyor";
      } else {
        remainingText = "Süresi doldu";
      }
    } else if (budget.periodType == "Yearly") {
      if (weeksRemaining > 0) {
        remainingText = "$weeksRemaining hafta kaldı";
      } else {
        remainingText = "Süresi doldu";
      }
    }

    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (context) => ShowBudgetPopup(userId: userId)),
      onSecondaryTap: () => showDialog(
          context: context,
          builder: (context) => BudgetActionsPopup(
                budget: budget,
                onBudgetUpdated: _loadHomeData,
              )),
      onLongPress: () => showDialog(
          context: context,
          builder: (context) => BudgetActionsPopup(
                budget: budget,
                onBudgetUpdated: _loadHomeData,
              )),
      child: SizedBox(
        width: 280,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Bütçe (${budget.month})",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        budget.periodType == "Weekly"
                            ? "Haftalık"
                            : budget.periodType == "Monthly"
                                ? "Aylık"
                                : "Yıllık",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Harcanan ₺${budget.spent.toStringAsFixed(0)} / ₺${budget.total.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                      value: percent, minHeight: 6, color: progressColor, backgroundColor: Colors.grey[300]),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("%$percentText", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(
                      remainingText,
                      style: TextStyle(
                        fontSize: 12,
                        color: daysRemaining < 7 ? Colors.orange : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewBudgetCard(BuildContext context, int userId) {
    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (context) => AddBudgetPopup(userId: userId, onBudgetAdded: _loadHomeData)),
      child: SizedBox(
        width: 180,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 40, color: Colors.black54),
                SizedBox(height: 8),
                Text("New Budget +",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetWorthCard(double total) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Net Değer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(currencyFormat.format(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 20),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Son İşlemler", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("Henüz işlem bulunmuyor", style: TextStyle(color: Colors.grey))),
              ),
            ],
          ),
        ),
      );
    }

    final sortedTx = List<Transaction>.from(transactions);
    sortedTx.sort((a, b) {
      final dateA = _parseDateTime(a.transactionDate, a.transactionTime);
      final dateB = _parseDateTime(b.transactionDate, b.transactionTime);
      return dateB.compareTo(dateA);
    });

    final Map<String, List<Transaction>> grouped = {};
    for (final tx in sortedTx) {
      final dateKey = _formatDateKey(tx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Son İşlemler", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ...entry.value.map((tx) => _buildTransactionItem(tx)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final isIncome = tx.transactionType == "Income";
    final amount = tx.transactionAmount;
    final color = isIncome ? Colors.green : Colors.red;
    final timeFormatted = _formatTime(tx.transactionTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.transactionTitle, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(
                  "${tx.transactionCategory} • $timeFormatted",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}₺${amount.abs().toStringAsFixed(0)}",
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final timeParts = timeStr.split(':');
      if (timeParts.length >= 2) {
        return DateTime(date.year, date.month, date.day,
            int.tryParse(timeParts[0]) ?? 0, int.tryParse(timeParts[1]) ?? 0);
      }
      return date;
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDateKey(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
      return "${date.day} ${months[date.month - 1]}";
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }
}