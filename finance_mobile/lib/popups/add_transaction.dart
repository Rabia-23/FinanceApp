import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../models/home_models.dart';

class AddTransactionPopup extends StatefulWidget {
  final String userId;
  final VoidCallback? onTransactionAdded;

  const AddTransactionPopup({
    super.key,
    required this.userId,
    this.onTransactionAdded,
  });

  @override
  State<AddTransactionPopup> createState() => _AddTransactionPopupState();
}

class _AddTransactionPopupState extends State<AddTransactionPopup> {
  String selectedType = "Gider";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Account? selectedAccount;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final HomeService _homeService = HomeService();

  List<Account> _accounts = [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final userId = int.tryParse(widget.userId) ?? 0;
      final accounts = await _homeService.getAccounts(userId);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoadingAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAccounts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hesaplar yüklenemedi: $e")),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && mounted) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 100 : 20,
        vertical: isWideScreen ? 60 : 40,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: isWideScreen ? 600 : double.infinity),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Yeni İşlem Ekle",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isWideScreen ? _buildWebForm() : _buildMobileForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌐 WEB FORM (İki Kolonlu)
  Widget _buildWebForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İşlem Türü & Tarih/Saat
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: "İşlem Türü",
                child: _buildTypeDropdown(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeField()),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Tutar & Banka Hesabı
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: "Tutar (₺)",
                child: _buildTextField(
                  controller: amountController,
                  hint: "0.00",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildField(
                label: "Banka Hesabı",
                child: _buildAccountDropdown(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Başlık & Kategori
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: "Başlık",
                child: _buildTextField(
                  controller: titleController,
                  hint: "örn: Market Alışverişi",
                  prefixIcon: Icons.title,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildField(
                label: "Kategori",
                child: _buildTextField(
                  controller: categoryController,
                  hint: "örn: Alışveriş",
                  prefixIcon: Icons.category,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Not
        _buildField(
          label: "Not (Opsiyonel)",
          child: _buildTextField(
            controller: noteController,
            hint: "İşlem hakkında kısa not",
            maxLines: 3,
            prefixIcon: Icons.note,
          ),
        ),
        const SizedBox(height: 28),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              "İşlem Ekle",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 📱 MOBILE FORM (Tek Kolon)
  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(label: "İşlem Türü", child: _buildTypeDropdown()),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildDateField()),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeField()),
          ],
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Tutar (₺)",
          child: _buildTextField(
            controller: amountController,
            hint: "0.00",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money,
          ),
        ),
        const SizedBox(height: 16),

        _buildField(label: "Banka Hesabı", child: _buildAccountDropdown()),
        const SizedBox(height: 16),

        _buildField(
          label: "Başlık",
          child: _buildTextField(
            controller: titleController,
            hint: "örn: Market Alışverişi",
            prefixIcon: Icons.title,
          ),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Kategori",
          child: _buildTextField(
            controller: categoryController,
            hint: "örn: Alışveriş",
            prefixIcon: Icons.category,
          ),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Not (Opsiyonel)",
          child: _buildTextField(
            controller: noteController,
            hint: "İşlem hakkında kısa not",
            maxLines: 3,
            prefixIcon: Icons.note,
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "İşlem Ekle",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // HELPER WIDGETS
  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.grey[600]) : null,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 12 : 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.swap_horiz, size: 20, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(value: "Gelir", child: Text("Gelir")),
        DropdownMenuItem(value: "Gider", child: Text("Gider")),
      ],
      onChanged: (v) => setState(() => selectedType = v!),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tarih",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}",
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                hintStyle: const TextStyle(color: Colors.black87),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saat",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                hintStyle: const TextStyle(color: Colors.black87),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDropdown() {
    if (_isLoadingAccounts) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text(
          "Henüz hesap eklenmemiş",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return DropdownButtonFormField<Account>(
      initialValue: selectedAccount,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.account_balance, size: 20, color: Colors.grey[600]),
        hintText: "Hesap seçin",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: _accounts
          .map((acc) => DropdownMenuItem<Account>(
                value: acc,
                child: Text(
                  "${acc.accountName} (${acc.accountBalance.toStringAsFixed(0)} ${acc.currency})",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedAccount = v),
    );
  }

  Future<void> _submitTransaction() async {
    if (amountController.text.isEmpty ||
        titleController.text.isEmpty ||
        categoryController.text.isEmpty ||
        selectedAccount == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm zorunlu alanları doldurun.")),
      );
      return;
    }

    final backendType = selectedType == "Gelir" ? "Income" : "Expense";

    final formattedDate = "${selectedDate.year.toString().padLeft(4, '0')}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}T00:00:00";

    final formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:"
        "${selectedTime.minute.toString().padLeft(2, '0')}:00";

    final model = CreateTransactionModel(
      userId: int.parse(widget.userId),
      accountId: selectedAccount!.accountId,
      transactionType: backendType,
      transactionTitle: titleController.text,
      transactionCategory: categoryController.text,
      transactionAmount: double.parse(amountController.text),
      transactionNote: noteController.text.isEmpty ? null : noteController.text,
      transactionDate: formattedDate,
      transactionTime: formattedTime,
    );

    try {
      final result = await _homeService.addTransaction(model);

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İşlem başarıyla eklendi.")),
        );
        widget.onTransactionAdded?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bir hata oluştu, tekrar deneyin.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }
}