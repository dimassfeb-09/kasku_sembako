import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class ConnectedDeviceSection extends StatelessWidget {
  final String macAddress;
  final VoidCallback onPrintTest;
  final VoidCallback onDisconnect;

  const ConnectedDeviceSection({
    super.key,
    required this.macAddress,
    required this.onPrintTest,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.success.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: _C.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text('Printer Terhubung',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.success)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('AKTIF',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _C.success, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _C.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(RemixIcons.printer_line, color: _C.success, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bluetooth Thermal Printer',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary)),
                    const SizedBox(height: 2),
                    Text(macAddress,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: _C.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrintTest,
                  icon: const Icon(RemixIcons.play_line, size: 16),
                  label: const Text('Test Print', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.success,
                    side: BorderSide(color: _C.success.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDisconnect,
                  icon: const Icon(RemixIcons.link_unlink, size: 16),
                  label: const Text('Putuskan', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
