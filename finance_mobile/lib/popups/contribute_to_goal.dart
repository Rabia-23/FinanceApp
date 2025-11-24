import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../services/home_service.dart';
import '../models/goal_models.dart';
import '../models/home_models.dart';

class ContributeToGoalPopup extends StatefulWidget {
  final Goal goal;
  final int userId;
  final VoidCallback? onContributed;

  const ContributeToGoalPopup({
    super.key,
    required this.goal,
    required this.userId,
    this.onContributed,
  });

  @override
  State<ContributeToGoalPopup> createState() => _ContributeToGoalPopupState();
}

class _ContributeToGoalPopupState extends State<ContributeToGoalPopup> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  Account? _selectedAccount;

  final GoalService _goalService = GoalService();
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
      final accounts = await _homeService.getAccounts(widget.userId);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoadingAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAccounts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 120 : 20,
        vertical: isWideScreen ? 80 : 60,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.savings_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.goal.goalName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Hedefe Katkı Yap",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade50, Colors.green.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.account_balance_wallet,
                            label: "Mevcut",
                            value: "₺${widget.goal.currentAmount.toStringAsFixed(2)}",
                            valueColor: Colors.black87,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.flag,
                            label: "Hedef",
                            value: "₺${widget.goal.targetAmount.toStringAsFixed(2)}",
                            valueColor: Colors.black87,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.trending_up,
                            label: "Kalan",
                            value: "₺${remaining.toStringAsFixed(2)}",
                            valueColor: Colors.green.shade700,
                          ),
                          const SizedBox(height: 16),
                          // Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "İlerleme",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${(widget.goal.progress * 100).toInt()}%",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: widget.goal.progress,
                                  backgroundColor: Colors.white,
                                  color: Colors.green.shade600,
                                  minHeight: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account Selection
                    _buildField(
                      label: "Hangi Hesaptan?",
                      child: _buildAccountDropdown(),
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    _buildField(
                      label: "Katkı Miktarı (₺)",
                      child: _buildTextField(
                        controller: _amountController,
                        hint: "0.00",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Note
                    _buildField(
                      label: "Not (Opsiyonel)",
                      child: _buildTextField(
                        controller: _noteController,
                        hint: "Örn: Aylık tasarruf",
                        maxLines: 2,
                        prefixIcon: Icons.note,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: isWideScreen ? 52 : 48,
                      child: ElevatedButton.icon(
                        onPressed: _submitContribution,
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          "Katkı Ekle",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 12 : 16,
          vertical: 14,
        ),
      ),
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
      initialValue: _selectedAccount,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: "Hesap seçin",
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.account_balance, size: 20, color: Colors.grey[600]),
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
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: _accounts
          .map((acc) => DropdownMenuItem<Account>(
                value: acc,
                child: Text(
                  "${acc.accountName} (₺${acc.accountBalance.toStringAsFixed(2)})",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedAccount = v),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.green.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitContribution() async {
    if (_selectedAccount == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen hesap ve miktar seçin.")),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geçerli bir miktar girin.")),
      );
      return;
    }

    if (amount > _selectedAccount!.accountBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yetersiz bakiye.")),
      );
      return;
    }

    try {
      final model = ContributeToGoalModel(
        accountId: _selectedAccount!.accountId,
        amount: amount,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      final success = await _goalService.contributeToGoal(widget.goal.goalId, model);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Katkı başarıyla eklendi.")),
        );
        widget.onContributed?.call();
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