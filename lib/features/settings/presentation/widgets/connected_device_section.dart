import 'package:flutter/material.dart';
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
      decoration: BoxDecoration(
        color: _C.successLight.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.success.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: _C.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Printer Terhubung & Aktif',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _C.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.success.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.print_rounded,
                  color: _C.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bluetooth Thermal Printer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      macAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: _C.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrintTest,
                  icon: const Icon(Icons.playlist_play_rounded, size: 18),
                  label: const Text('Test Print'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.success,
                    side: BorderSide(color: _C.success.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDisconnect,
                  icon: const Icon(Icons.link_off_rounded, size: 18),
                  label: const Text('Putuskan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
