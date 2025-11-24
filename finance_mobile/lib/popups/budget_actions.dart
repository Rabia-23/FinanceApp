import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../models/home_models.dart';

class BudgetActionsPopup extends StatefulWidget {
  final Budget budget;
  final VoidCallback? onBudgetUpdated;

  const BudgetActionsPopup({
    super.key,
    required this.budget,
    this.onBudgetUpdated,
  });

  @override
  State<BudgetActionsPopup> createState() => _BudgetActionsPopupState();
}

class _BudgetActionsPopupState extends State<BudgetActionsPopup> {
  final HomeService _homeService = HomeService();
  final TextEditingController _amountController = TextEditingController();
  
  bool _isEditing = false;
  String _selectedPeriod = "";
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.budget.amountLimit.toStringAsFixed(0);
    _selectedPeriod = widget.budget.periodType;
    _startDate = DateTime.parse(widget.budget.startDate);
  }

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

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bütçeyi Sil'),
        content: const Text('Bu bütçeyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _homeService.deleteBudget(widget.budget.budgetId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bütçe silindi.')),
        );
        widget.onBudgetUpdated?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silme işlemi başarısız.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _handleUpdate() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bütçe limiti girin.')),
      );
      return;
    }

    try {
      final endDate = _calculateEndDate(_startDate, _selectedPeriod);

      final formattedStartDate =
          "${_startDate.year.toString().padLeft(4, '0')}-"
          "${_startDate.month.toString().padLeft(2, '0')}-"
          "${_startDate.day.toString().padLeft(2, '0')}";

      final formattedEndDate =
          "${endDate.year.toString().padLeft(4, '0')}-"
          "${endDate.month.toString().padLeft(2, '0')}-"
          "${endDate.day.toString().padLeft(2, '0')}";

      final model = UpdateBudgetModel(
        periodType: _selectedPeriod,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        amountLimit: double.parse(_amountController.text),
        spentAmount: widget.budget.spentAmount,
      );

      final success = await _homeService.updateBudget(
          widget.budget.budgetId, model);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bütçe güncellendi.')),
        );
        widget.onBudgetUpdated?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncelleme başarısız.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
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
                    "Bütçe Yönetimi",
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

              if (!_isEditing) ...[
                // GÖRÜNTÜLEME MODU
                _buildInfoRow("Periyot", _selectedPeriod == "Weekly"
                    ? "Haftalık"
                    : _selectedPeriod == "Monthly"
                        ? "Aylık"
                        : "Yıllık"),
                _buildInfoRow("Başlangıç", 
                    "${_startDate.day.toString().padLeft(2, '0')}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.year}"),
                _buildInfoRow("Bitiş", 
                    "${endDate.day.toString().padLeft(2, '0')}.${endDate.month.toString().padLeft(2, '0')}.${endDate.year}"),
                _buildInfoRow("Limit", "₺${widget.budget.amountLimit.toStringAsFixed(0)}"),
                _buildInfoRow("Harcanan", "₺${widget.budget.spentAmount.toStringAsFixed(0)}"),
                
                const SizedBox(height: 24),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit),
                        label: const Text("Güncelle"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Sil"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // DÜZENLEME MODU
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
                  items: ["Weekly", "Monthly", "Yearly"]
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

                // Kaydet / İptal
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("İptal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Kaydet",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}