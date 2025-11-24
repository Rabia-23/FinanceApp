import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../models/home_models.dart';

class AddBudgetPopup extends StatefulWidget {
  final int userId;
  final VoidCallback? onBudgetAdded;

  const AddBudgetPopup({
    super.key,
    required this.userId,
    this.onBudgetAdded,
  });

  @override
  State<AddBudgetPopup> createState() => _AddBudgetPopupState();
}

class _AddBudgetPopupState extends State<AddBudgetPopup> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedPeriod = "Monthly";
  DateTime _startDate = DateTime.now();

  final HomeService _homeService = HomeService();

  final List<String> _periods = ["Weekly", "Monthly", "Yearly"];

  DateTime _calculateEndDate(DateTime start, String period) {
    switch (period) {
      case "Weekly":
        return start.add(const Duration(days: 7));
      case "Monthly":
        return DateTime(start.year, start.month + 1, start.day);
      case "Yearly":
        return DateTime(start.year + 1, start.month, start.day);
      default:
        return start.add(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final endDate = _calculateEndDate(_startDate, _selectedPeriod);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Yeni Bütçe",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Period Type
              const Text("Periyot",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedPeriod,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _periods
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p == "Weekly"
                              ? "Haftalık"
                              : p == "Monthly"
                                  ? "Aylık"
                                  : "Yıllık"),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPeriod = v!),
              ),
              const SizedBox(height: 16),

              // Başlangıç Tarihi
              const Text("Başlangıç Tarihi",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText:
                          "${_startDate.day.toString().padLeft(2, '0')}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.year}",
                      suffixIcon:
                          const Icon(Icons.calendar_today, size: 18),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bitiş Tarihi (sadece gösterim)
              const Text("Bitiş Tarihi",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "${endDate.day.toString().padLeft(2, '0')}.${endDate.month.toString().padLeft(2, '0')}.${endDate.year}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "(Otomatik)",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bütçe Limiti
              const Text("Bütçe Limiti (₺)",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "0.00",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ekle Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Lütfen bütçe limiti girin.")),
                      );
                      return;
                    }

                    try {
                      final formattedStartDate =
                          "${_startDate.year.toString().padLeft(4, '0')}-"
                          "${_startDate.month.toString().padLeft(2, '0')}-"
                          "${_startDate.day.toString().padLeft(2, '0')}";

                      final formattedEndDate =
                          "${endDate.year.toString().padLeft(4, '0')}-"
                          "${endDate.month.toString().padLeft(2, '0')}-"
                          "${endDate.day.toString().padLeft(2, '0')}";

                      final model = CreateBudgetModel(
                        userId: widget.userId,
                        periodType: _selectedPeriod,
                        startDate: formattedStartDate,
                        endDate: formattedEndDate,
                        amountLimit: double.parse(_amountController.text),
                      );

                      final success = await _homeService.addBudget(model);

                      if (!mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Bütçe başarıyla eklendi.")),
                        );
                        widget.onBudgetAdded?.call();
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Bir hata oluştu, tekrar deneyin.")),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Hata: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Bütçe Ekle",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}