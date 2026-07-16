import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class RegisterStepConfirm extends StatelessWidget {
  final String ownerName;
  final String email;
  final String businessName;
  final String businessCategory;
  final String phone;
  final String address;

  const RegisterStepConfirm({
    super.key,
    required this.ownerName,
    required this.email,
    required this.businessName,
    required this.businessCategory,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Icon(RemixIcons.checkbox_circle_fill, size: 64, color: _C.success),
          const SizedBox(height: 16),
          const Text(
            'Konfirmasi Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan data sudah benar sebelum mendaftar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
          const SizedBox(height: 32),
          _SummaryRow(icon: RemixIcons.user_3_line, label: 'Nama Pemilik', value: ownerName),
          const Divider(height: 1, color: _C.borderLight),
          _SummaryRow(icon: RemixIcons.mail_line, label: 'Email', value: email),
          const Divider(height: 1, color: _C.borderLight),
          _SummaryRow(icon: RemixIcons.store_2_line, label: 'Nama Bisnis', value: businessName),
          const Divider(height: 1, color: _C.borderLight),
          _SummaryRow(icon: RemixIcons.price_tag_3_line, label: 'Kategori', value: businessCategory),
          const Divider(height: 1, color: _C.borderLight),
          _SummaryRow(icon: RemixIcons.phone_line, label: 'Telepon', value: phone.isNotEmpty ? phone : '-'),
          const Divider(height: 1, color: _C.borderLight),
          _SummaryRow(icon: RemixIcons.map_pin_line, label: 'Alamat', value: address.isNotEmpty ? address : '-'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _C.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13, color: _C.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary)),
          ),
        ],
      ),
    );
  }
}
