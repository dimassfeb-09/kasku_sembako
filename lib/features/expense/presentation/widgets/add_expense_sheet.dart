import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AddExpenseSheet extends StatefulWidget {
  final TextEditingController categoryController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final List<(String, IconData)> quickCategories;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const AddExpenseSheet({
    super.key,
    required this.categoryController,
    required this.amountController,
    required this.notesController,
    required this.quickCategories,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddExpenseSheet> createState() => AddExpenseSheetState();
}

class ExpenseDarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const ExpenseDarkTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC), // Slate 50 Background fill
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // 12px corners
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ), // Slate 200 border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddExpenseSheetState extends State<AddExpenseSheet> {
  String? _selectedCategory;

  void _selectCategory(String cat) {
    setState(() => _selectedCategory = cat);
    widget.categoryController.text = cat;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white, // Surface White
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ), // 24px top corner radius
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0), // Slate 200
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Tambah Pengeluaran',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Quick category chips
            const Text(
              'PILIH KATEGORI CEPAT',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.quickCategories.map((cat) {
                final isSelected = _selectedCategory == cat.$1;
                return GestureDetector(
                  onTap: () => _selectCategory(cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFF8FAFC), // Teal or Slate 50
                      borderRadius: BorderRadius.circular(20), // Pill chip
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0), // Slate 200
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.$2,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.$1,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Category field
            ExpenseDarkTextField(
              controller: widget.categoryController,
              label: 'Kategori',
              hint: 'Contoh: Listrik, Gaji, Sewa...',
              icon: Icons.label_outline_rounded,
              onChanged: (val) => setState(() => _selectedCategory = null),
            ),
            const SizedBox(height: 16),
            // Amount field
            ExpenseDarkTextField(
              controller: widget.amountController,
              label: 'Jumlah Pengeluaran (Rp)',
              hint: '0',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Notes field
            ExpenseDarkTextField(
              controller: widget.notesController,
              label: 'Catatan (opsional)',
              hint: 'Tambahkan catatan...',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 28),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                      ), // Slate 200
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // 12px corners
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: widget.onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Teal
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // 12px corners
                      ),
                    ),
                    child: const Text(
                      'Simpan Pengeluaran',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
