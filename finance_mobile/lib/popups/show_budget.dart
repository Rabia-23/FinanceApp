import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/home_models.dart';
import '../services/home_service.dart';

class ShowBudgetPopup extends StatefulWidget {
  final int userId;

  const ShowBudgetPopup({super.key, required this.userId});

  @override
  State<ShowBudgetPopup> createState() => _ShowBudgetPopupState();
}

class _ShowBudgetPopupState extends State<ShowBudgetPopup> {
  late Future<List<Budget>> _budgetsFuture;
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    _budgetsFuture = _homeService.getBudgets(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst başlık ve kapatma butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.black87),
                    SizedBox(width: 6),
                    Text(
                      "Bütçe Geçmişi",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bütçe satırları (async veriler)
            FutureBuilder<List<Budget>>(
              future: _budgetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Bütçeler yüklenirken hata oluştu: ${snapshot.error}",
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Henüz bütçe verisi yok."),
                    ),
                  );
                } else {
                  final budgets = snapshot.data!;
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: budgets
                            .map(
                              (b) => Column(
                                children: [
                                  _buildBudgetRow(
                                      b.month, b.spent, b.total, currencyFormat),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(
      String month, double spent, double total, NumberFormat currencyFormat) {
    final percent = (spent / total * 100).clamp(0, 100);
    final progress = (spent / total).clamp(0.0, 1.0);

    // Renk durumuna göre
    Color progressColor;
    if (percent < 50) {
      progressColor = Colors.green;
    } else if (percent < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(month, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              "%${percent.toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: progressColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(currencyFormat.format(spent),
                style: const TextStyle(fontSize: 13)),
            Text(currencyFormat.format(total),
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}