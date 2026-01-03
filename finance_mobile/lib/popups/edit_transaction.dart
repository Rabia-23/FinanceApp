import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/home_service.dart';
import '../models/home_models.dart';
import '../constants/categories.dart';

class EditTransactionPopup extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onTransactionUpdated;

  const EditTransactionPopup({
    super.key,
    required this.transaction,
    required this.onTransactionUpdated,
  });

  @override
  State<EditTransactionPopup> createState() => _EditTransactionPopupState();
}

class _EditTransactionPopupState extends State<EditTransactionPopup> {
  final HomeService _homeService = HomeService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.transactionTitle);
    _amountController = TextEditingController(text: widget.transaction.transactionAmount.abs().toString());
    _noteController = TextEditingController(text: widget.transaction.transactionNote);
    
    _selectedType = widget.transaction.transactionType;
    _selectedCategory = widget.transaction.transactionCategory;
    _selectedDate = DateTime.parse(widget.transaction.transactionDate);
    
    // Time parsing
    final timeParts = widget.transaction.transactionTime.split(':');
    _selectedTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 0,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final finalAmount = _selectedType == "Expense" ? -amount.abs() : amount.abs();

      final model = UpdateTransactionModel(
        transactionId: widget.transaction.transactionId,
        transactionType: _selectedType,
        transactionTitle: _titleController.text.trim(),
        transactionCategory: _selectedCategory,
        transactionAmount: finalAmount,
        transactionNote: _noteController.text.trim(),
        transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        transactionTime: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      );

      await _homeService.updateTransaction(model);

      if (mounted) {
        Navigator.pop(context);
        widget.onTransactionUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İşlem başarıyla güncellendi")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "İşlemi Düzenle",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Başlık
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Başlık",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Başlık gerekli" : null,
                ),
                const SizedBox(height: 16),

                // Tür
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: "Tür",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Income", child: Text("Gelir")),
                    DropdownMenuItem(value: "Expense", child: Text("Gider")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        // Türe göre ilk kategoriyi seç
                        final categories = Categories.getCategoriesByType(value);
                        _selectedCategory = categories.first;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Kategori
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(),
                  ),
                  items: Categories.getCategoriesByType(_selectedType)
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Tutar
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tutar",
                    border: OutlineInputBorder(),
                    prefixText: "₺",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Tutar gerekli";
                    if (double.tryParse(value) == null) return "Geçerli bir sayı girin";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tarih ve Saat
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(_selectedTime.format(context)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Not
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: "Not (Opsiyonel)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("İptal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Güncelle",
                                style: TextStyle(color: Colors.white),
                              ),
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
}
