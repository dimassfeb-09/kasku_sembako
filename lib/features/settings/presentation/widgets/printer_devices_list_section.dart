import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class PrinterDevicesListSection extends StatelessWidget {
  final List<BluetoothInfo> devices;
  final String? connectedMacAddress;
  final ValueChanged<String> onConnect;

  const PrinterDevicesListSection({
    super.key,
    required this.devices,
    required this.connectedMacAddress,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
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
                  Icons.bluetooth_rounded,
                  color: _C.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pilih Printer Bluetooth',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching_rounded,
                    size: 32,
                    color: _C.textMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tidak menemukan perangkat Bluetooth ter-pairing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _C.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastikan printer aktif dan sudah ter-pairing di pengaturan Bluetooth HP Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: _C.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: _C.border),
              itemBuilder: (context, index) {
                final device = devices[index];
                final isConnected = device.macAdress == connectedMacAddress;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _C.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.print_rounded,
                          color: isConnected ? _C.primary : _C.textSecondary,
                          size: 20,
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
                                fontWeight: FontWeight.bold,
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
                      if (isConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _C.successLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _C.success,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => onConnect(device.macAdress),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primaryLight,
                            foregroundColor: _C.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Hubungkan',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
