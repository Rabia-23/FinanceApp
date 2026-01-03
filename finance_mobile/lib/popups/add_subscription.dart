import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription_models.dart';

class AddSubscriptionPopup extends StatefulWidget {
  final int userId;
  final VoidCallback? onSubscriptionAdded;

  const AddSubscriptionPopup({
    super.key,
    required this.userId,
    this.onSubscriptionAdded,
  });

  @override
  State<AddSubscriptionPopup> createState() => _AddSubscriptionPopupState();
}

class _AddSubscriptionPopupState extends State<AddSubscriptionPopup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  String? _selectedCategory;

  final SubscriptionService _service = SubscriptionService();

  final List<String> _categories = [
    "Eğlence",
    "Fatura",
    "Sağlık",
    "Eğitim",
    "Diğer"
  ];

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
                    child: const Icon(Icons.subscriptions, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Yeni Abonelik Ekle",
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

  // WEB FORM
  Widget _buildWebForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Abonelik Adı & Kategori
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: "Abonelik Adı",
                child: _buildTextField(
                  controller: _nameController,
                  hint: "örn: Netflix",
                  prefixIcon: Icons.play_circle_outline,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildField(
                label: "Kategori",
                child: _buildCategoryDropdown(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Aylık Tutar & Ödeme Günü
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: "Aylık Tutar (₺)",
                child: _buildTextField(
                  controller: _amountController,
                  hint: "0.00",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildField(
                label: "Ödeme Günü (1-31)",
                child: _buildTextField(
                  controller: _dayController,
                  hint: "15",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              "Abonelik Ekle",
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

  // MOBILE FORM
  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: "Abonelik Adı",
          child: _buildTextField(
            controller: _nameController,
            hint: "örn: Netflix",
            prefixIcon: Icons.play_circle_outline,
          ),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Kategori",
          child: _buildCategoryDropdown(),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Aylık Tutar (₺)",
          child: _buildTextField(
            controller: _amountController,
            hint: "0.00",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money,
          ),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Ödeme Günü (1-31)",
          child: _buildTextField(
            controller: _dayController,
            hint: "15",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.calendar_today,
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Abonelik Ekle",
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
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        hintText: "Kategori seçin",
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.category, size: 20, color: Colors.grey[600]),
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
      items: _categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
      },
    );
  }

  Future<void> _submitSubscription() async {
    if (_nameController.text.isEmpty ||
        _selectedCategory == null ||
        _amountController.text.isEmpty ||
        _dayController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    final paymentDay = int.tryParse(_dayController.text);
    if (paymentDay == null || paymentDay < 1 || paymentDay > 31) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ödeme günü 1-31 arasında olmalı.")),
      );
      return;
    }

    try {
      final model = CreateSubscriptionModel(
        userId: widget.userId,
        subscriptionName: _nameController.text,
        subscriptionCategory: _selectedCategory!,
        monthlyFee: double.parse(_amountController.text),
        paymentDay: paymentDay,
      );

      final success = await _service.addSubscription(model);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Abonelik başarıyla eklendi.")),
        );
        widget.onSubscriptionAdded?.call();
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