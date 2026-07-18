import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class PrinterDevicesListSection extends StatelessWidget {
  final List<BluetoothInfo> devices;
  final List<String> savedMacs;
  final bool bluetoothOn;
  final ValueChanged<String> onConnect;
  final VoidCallback onScan;

  const PrinterDevicesListSection({
    super.key,
    required this.devices,
    required this.savedMacs,
    required this.bluetoothOn,
    required this.onConnect,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  RemixIcons.bluetooth_line,
                  color: _C.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pilih Printer Bluetooth',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onScan,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    RemixIcons.refresh_line,
                    size: 16,
                    color: _C.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!bluetoothOn)
            _EmptyState(
              icon: RemixIcons.bluetooth_line,
              title: 'Bluetooth tidak aktif',
              subtitle:
                  'Aktifkan Bluetooth di pengaturan HP, lalu pindai ulang.',
            )
          else if (devices.isEmpty)
            _EmptyState(
              icon: RemixIcons.bluetooth_line,
              title: 'Tidak ada perangkat ter-pairing',
              subtitle:
                  'Pairing printer thermal di pengaturan Bluetooth HP Anda, lalu pindai ulang.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Divider(height: 1, color: _C.borderLight),
              ),
              itemBuilder: (context, index) {
                final device = devices[index];
                final isSaved = savedMacs.contains(device.macAdress);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSaved ? _C.primaryLight : _C.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isSaved
                              ? RemixIcons.bluetooth_connect_line
                              : RemixIcons.printer_line,
                          size: 20,
                          color: isSaved ? _C.primary : _C.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name.isEmpty
                                  ? 'Printer Thermal'
                                  : device.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              device.macAdress,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: _C.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSaved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _C.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Tersimpan',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _C.primary,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => onConnect(device.macAdress),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _C.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Hubungkan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _C.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 32, color: _C.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _C.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: _C.textMuted),
          ),
        ],
      ),
    );
  }
}
