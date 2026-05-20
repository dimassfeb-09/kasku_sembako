import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class NoConnectedDeviceSection extends StatelessWidget {
  const NoConnectedDeviceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: const Column(
        children: [
          Icon(Icons.print_disabled_rounded, size: 36, color: _C.textMuted),
          SizedBox(height: 12),
          Text(
            'Belum ada printer yang terhubung.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _C.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pilih perangkat Bluetooth di bawah untuk menyambungkan printer thermal Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: _C.textMuted),
          ),
        ],
      ),
    );
  }
}
