import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_input.dart';

typedef _C = AppColors;

class StoreProfileSection extends StatelessWidget {
  final String? logoPath;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;
  final VoidCallback onSaveProfile;

  const StoreProfileSection({
    super.key,
    required this.logoPath,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.onPickLogo,
    required this.onRemoveLogo,
    required this.onSaveProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  color: _C.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Desain & Profil Struk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Picker Logo Toko
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: logoPath != null ? onRemoveLogo : onPickLogo,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: logoPath != null
                            ? _C.primary.withOpacity(0.5)
                            : _C.border,
                        width: 1,
                        style: logoPath != null
                            ? BorderStyle.solid
                            : BorderStyle.none,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _C.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (logoPath != null &&
                            File(logoPath!).existsSync()) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(logoPath!),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ] else ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 26,
                                color: _C.primary.withOpacity(0.8),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Logo Toko',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _C.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  logoPath != null
                      ? 'Ketuk logo untuk menghapus'
                      : 'Ketuk untuk mengunggah logo',
                  style: TextStyle(
                    fontSize: 11,
                    color: logoPath != null ? _C.error : _C.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Form Fields
          AppInput(
            controller: nameController,
            label: 'Nama Toko',
            hintText: 'Contoh: Kasirku Sembako',
            prefixIcon: Icons.store_rounded,
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: addressController,
            label: 'Alamat Toko',
            hintText: 'Contoh: Jl. Merdeka No. 45',
            prefixIcon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: phoneController,
            label: 'Nomor Telepon Toko',
            hintText: 'Contoh: 08123456789',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: onSaveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Simpan Profil Struk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
