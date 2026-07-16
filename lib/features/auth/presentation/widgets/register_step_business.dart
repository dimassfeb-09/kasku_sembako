import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class RegisterStepBusiness extends StatelessWidget {
  final TextEditingController businessController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController categoryController;

  static const List<String> categories = [
    'Toko Kelontong',
    'Minimarket',
    'Supermarket',
    'Warung Makan',
    'Restoran',
    'Toko Pakaian',
    'Toko Elektronik',
    'Toko Obat / Apotek',
    'Toko Pertanian',
    'Toko Bangunan',
    'Jasa / Servis',
    'Lainnya',
  ];

  const RegisterStepBusiness({
    super.key,
    required this.businessController,
    required this.phoneController,
    required this.addressController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categoryController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Data Bisnis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi toko untuk struk dan pengaturan.',
            style: TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
          const SizedBox(height: 32),
          AppInput(
            label: 'Nama Bisnis / Toko',
            controller: businessController,
            prefixIcon: RemixIcons.store_2_line,
            hintText: 'Contoh: Toko Sembako Makmur',
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KATEGORI BISNIS',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: _C.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory.isEmpty ? null : selectedCategory,
                hint: Text(
                  'Pilih kategori',
                  style: TextStyle(fontSize: 13, color: _C.textMuted),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                    .toList(),
                onChanged: onCategoryChanged,
                decoration: InputDecoration(
                  prefixIcon: Icon(RemixIcons.price_tag_3_line, size: 18, color: _C.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _C.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppInput(
            label: 'Nomor Telepon',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: RemixIcons.phone_line,
            hintText: '08xxxxxxxxxx',
          ),
          const SizedBox(height: 20),
          AppInput(
            label: 'Alamat',
            controller: addressController,
            maxLines: 3,
            prefixIcon: RemixIcons.map_pin_line,
            hintText: 'Jl. Contoh No. 123, Kota',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
