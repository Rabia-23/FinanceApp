import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../models/home_models.dart';

class AddAccountPopup extends StatefulWidget {
  final String userId;
  final VoidCallback? onAccountAdded;

  const AddAccountPopup({
    super.key,
    required this.userId,
    this.onAccountAdded,
  });

  @override
  State<AddAccountPopup> createState() => _AddAccountPopupState();
}

class _AddAccountPopupState extends State<AddAccountPopup> {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountBalanceController = TextEditingController();

  final HomeService _homeService = HomeService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Yeni Banka Hesabı",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text("Hesap Adı", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: accountNameController,
                decoration: InputDecoration(
                  hintText: "örn: Ziraat Bankası",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text("Bakiye (₺)", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: accountBalanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "0.00",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (accountNameController.text.isEmpty ||
                        accountBalanceController.text.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Lütfen tüm alanları doldurun.")),
                      );
                      return;
                    }

                    final model = CreateAccountModel(
                      userId: int.parse(widget.userId),
                      accountName: accountNameController.text,
                      accountBalance:
                          double.tryParse(accountBalanceController.text) ?? 0,
                      currency: "TRY",
                    );

                    final success = await _homeService.addAccount(model);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(success
                              ? "Hesap başarıyla eklendi."
                              : "Hata oluştu, tekrar deneyin.")),
                    );

                    if (success && mounted) {
                      widget.onAccountAdded?.call();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Hesap Ekle",
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