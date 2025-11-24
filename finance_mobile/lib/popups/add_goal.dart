import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../models/goal_models.dart';

class AddGoalPopup extends StatefulWidget {
  final int userId;
  final VoidCallback? onGoalAdded;

  const AddGoalPopup({
    super.key,
    required this.userId,
    this.onGoalAdded,
  });

  @override
  State<AddGoalPopup> createState() => _AddGoalPopupState();
}

class _AddGoalPopupState extends State<AddGoalPopup> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedGoalType;

  final GoalService _service = GoalService();

  final List<String> _goalTypes = [
    "Tasarruf Hedefi (örn: Tatil için birikim)",
    "Yatırım Hedefi (örn: Borsa, altın)",
    "Borç Ödeme Hedefi (örn: kredi kartı borcu)"
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
        constraints: BoxConstraints(maxWidth: isWideScreen ? 650 : double.infinity),
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
                    child: const Icon(Icons.flag, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Yeni Hedef Ekle",
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

  // 🌐 WEB FORM
  Widget _buildWebForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hedef Türü (Full Width)
        _buildField(
          label: "Hedef Türü",
          child: _buildGoalTypeDropdown(),
        ),
        const SizedBox(height: 20),

        // Hedef Adı & Hedef Miktar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildField(
                label: "Hedef Adı",
                child: _buildTextField(
                  controller: _goalNameController,
                  hint: "örn: Yaz Tatili",
                  prefixIcon: Icons.edit_outlined,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildField(
                label: "Hedef Miktar (₺)",
                child: _buildTextField(
                  controller: _goalAmountController,
                  hint: "0.00",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Başlangıç & Bitiş Tarihleri
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStartDateField()),
            const SizedBox(width: 16),
            Expanded(child: _buildEndDateField()),
          ],
        ),
        const SizedBox(height: 28),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              "Hedef Ekle",
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

  // 📱 MOBILE FORM
  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: "Hedef Türü",
          child: _buildGoalTypeDropdown(),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Hedef Adı",
          child: _buildTextField(
            controller: _goalNameController,
            hint: "örn: Yaz Tatili",
            prefixIcon: Icons.edit_outlined,
          ),
        ),
        const SizedBox(height: 16),

        _buildField(
          label: "Hedef Miktar (₺)",
          child: _buildTextField(
            controller: _goalAmountController,
            hint: "0.00",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money,
          ),
        ),
        const SizedBox(height: 16),

        _buildStartDateField(),
        const SizedBox(height: 16),

        _buildEndDateField(),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Hedef Ekle",
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

  Widget _buildGoalTypeDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedGoalType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.category, size: 20, color: Colors.grey[600]),
        hintText: "Hedef türü seçin",
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
      items: _goalTypes
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedGoalType = value);
      },
    );
  }

  Widget _buildStartDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Başlangıç Tarihi",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(
            text: _startDate == null
                ? ""
                : "${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.year}",
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _startDate = picked);
            }
          },
          decoration: InputDecoration(
            hintText: "dd.mm.yyyy",
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bitiş Tarihi",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(
            text: _endDate == null
                ? ""
                : "${_endDate!.day.toString().padLeft(2, '0')}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.year}",
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _endDate = picked);
            }
          },
          decoration: InputDecoration(
            hintText: "dd.mm.yyyy",
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _submitGoal() async {
    if (_goalNameController.text.isEmpty ||
        _selectedGoalType == null ||
        _goalAmountController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitiş tarihi başlangıç tarihinden önce olamaz.")),
      );
      return;
    }

    try {
      final formattedStartDate = "${_startDate!.year.toString().padLeft(4, '0')}-"
          "${_startDate!.month.toString().padLeft(2, '0')}-"
          "${_startDate!.day.toString().padLeft(2, '0')}";

      final formattedEndDate = "${_endDate!.year.toString().padLeft(4, '0')}-"
          "${_endDate!.month.toString().padLeft(2, '0')}-"
          "${_endDate!.day.toString().padLeft(2, '0')}";

      final model = CreateGoalModel(
        userId: widget.userId,
        goalType: _selectedGoalType!,
        goalName: _goalNameController.text,
        targetAmount: double.parse(_goalAmountController.text),
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      final success = await _service.addGoal(model);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hedef başarıyla eklendi.")),
        );
        widget.onGoalAdded?.call();
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