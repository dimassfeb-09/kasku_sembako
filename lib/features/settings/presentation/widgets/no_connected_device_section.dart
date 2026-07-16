import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class NoConnectedDeviceSection extends StatelessWidget {
  const NoConnectedDeviceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _C.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(RemixIcons.printer_line, color: _C.textMuted, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Belum ada printer terhubung',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary)),
                SizedBox(height: 2),
                Text('Pilih perangkat Bluetooth di bawah.',
                  style: TextStyle(fontSize: 12, color: _C.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
