import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lucide_icons/lucide_icons.dart';
import '../popups/add_transaction.dart';
import '../services/home_service.dart';
import '../services/user_service.dart';
import '../models/home_models.dart';
import '../csv/csv_helper.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final HomeService _homeService = HomeService();
  final ApiService _apiService = ApiService();

  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String? _userId;

  late List<DateTime> _availableMonths;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeMonths();
    _loadTransactions();
  }

  void _initializeMonths() {
    final now = DateTime.now();
    _availableMonths = List.generate(5, (index) => DateTime(now.year, now.month - index, 1));
    _selectedMonth = _availableMonths.first;
  }

  Future<void> _loadTransactions() async {
    try {
      final userId = await _apiService.getUserId();
      if (userId == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
        return;
      }

      _userId = userId;
      final transactions = await _homeService.getTransactions(int.parse(userId));

      if (mounted) {
        setState(() {
          _allTransactions = transactions;
          _filterByMonth();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  void _filterByMonth() {
    _filteredTransactions = _allTransactions.where((tx) {
      try {
        final txDate = DateTime.parse(tx.transactionDate);
        return txDate.year == _selectedMonth.year && txDate.month == _selectedMonth.month;
      } catch (e) {
        return false;
      }
    }).toList();

    _filteredTransactions.sort((a, b) {
      final dateA = _parseDateTime(a.transactionDate, a.transactionTime);
      final dateB = _parseDateTime(b.transactionDate, b.transactionTime);
      return dateB.compareTo(dateA);
    });
  }

  Future<void> _downloadCSV() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İndirilecek işlem bulunamadı")));
      return;
    }

    final csvRows = <String>[];
    csvRows.add('Başlık,Kategori,Tür,Tutar,Tarih,Saat,Not');

    for (final tx in _filteredTransactions) {
      final row = [
        '"${tx.transactionTitle}"',
        '"${tx.transactionCategory}"',
        tx.transactionType == "Income" ? "Gelir" : "Gider",
        tx.transactionAmount.toStringAsFixed(2),
        _formatDateForCSV(tx.transactionDate),
        _formatTime(tx.transactionTime),
        '"${tx.transactionNote}"',
      ].join(',');
      csvRows.add(row);
    }

    final csvContent = csvRows.join('\n');
    final fileName = 'islemler_${_getMonthFileName()}.csv';

    try {
      await CsvHelper.downloadCsv(csvContent, fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(kIsWeb ? "CSV dosyası indiriliyor..." : "CSV dosyası kaydedildi: $fileName")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("CSV indirme hatası: $e")));
      }
    }
  }

  String _getMonthFileName() => "${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}";

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
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in _filteredTransactions) {
      final dateKey = _formatDateKey(tx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

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
                "İşlemler",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _downloadCSV,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(LucideIcons.download, size: 18),
                label: const Text("CSV İndir"),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (_userId != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AddTransactionPopup(
                        userId: _userId!,
                        onTransactionAdded: _loadTransactions,
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
                label: const Text("Yeni İşlem",
                    style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
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
                  // Filter Bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "Filtrele",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<DateTime>(
                              value: _selectedMonth,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              onChanged: (DateTime? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedMonth = newValue;
                                    _filterByMonth();
                                  });
                                }
                              },
                              items: _availableMonths.map<DropdownMenuItem<DateTime>>((DateTime month) {
                                return DropdownMenuItem<DateTime>(
                                  value: month,
                                  child: Text(_formatMonthYear(month)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "${_filteredTransactions.length} işlem",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Transactions List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredTransactions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Bu ayda işlem bulunmuyor",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Yeni bir işlem eklemek için üstteki butona tıklayın",
                                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.all(20),
                                children: grouped.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, bottom: 12, left: 4),
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      ...entry.value.map((tx) => _buildWebTransactionItem(tx)),
                                    ],
                                  );
                                }).toList(),
                              ),
                  ),
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
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in _filteredTransactions) {
      final dateKey = _formatDateKey(tx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.deepPurple),
                  SizedBox(width: 6),
                  Text(
                    "Finans Takip",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple),
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
                  isActive: true,
                  onTap: () {},
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
                  onTap: () => Navigator.pushNamed(context, '/currency'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              const Text("İşlemler", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _downloadCSV,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: Colors.black87),
                ),
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text("CSV", style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_userId != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AddTransactionPopup(
                        userId: _userId!,
                        onTransactionAdded: _loadTransactions,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text("İşlem Ekle", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Tüm İşlemler", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DateTime>(
                            value: _selectedMonth,
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 14),
                            onChanged: (DateTime? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedMonth = newValue;
                                  _filterByMonth();
                                });
                              }
                            },
                            items: _availableMonths.map<DropdownMenuItem<DateTime>>((DateTime month) {
                              return DropdownMenuItem<DateTime>(
                                value: month,
                                child: Text(_formatMonthYear(month)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${_filteredTransactions.length} işlem bulundu",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredTransactions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text("Bu ayda işlem bulunmuyor", style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              )
                            : ListView(
                                children: grouped.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12, bottom: 6),
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
            ),
          ),
        ],
      ),
    );
  }

  // WEB TRANSACTION ITEM
  Widget _buildWebTransactionItem(Transaction tx) {
    final isIncome = tx.transactionType == "Income";
    final amount = tx.transactionAmount;
    final color = isIncome ? Colors.green : Colors.red;
    final timeFormatted = _formatTime(tx.transactionTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? LucideIcons.trendingUp : LucideIcons.trendingDown,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.transactionTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tx.transactionCategory,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeFormatted,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}₺${amount.abs().toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  // MOBILE TRANSACTION ITEM
  Widget _buildTransactionItem(Transaction tx) {
    final isIncome = tx.transactionType == "Income";
    final amount = tx.transactionAmount;
    final color = isIncome ? Colors.green : Colors.red;
    final timeFormatted = _formatTime(tx.transactionTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(isIncome ? LucideIcons.trendingUp : LucideIcons.trendingDown, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.transactionTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${tx.transactionCategory} • $timeFormatted",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}₺${amount.abs().toStringAsFixed(0)}",
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
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
        return DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(timeParts[0]) ?? 0,
          int.tryParse(timeParts[1]) ?? 0,
        );
      }
      return date;
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDateKey(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık'
      ];
      return "${date.day} ${months[date.month - 1]}";
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateForCSV(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
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

  String _formatMonthYear(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

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