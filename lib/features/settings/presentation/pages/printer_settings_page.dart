import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event_state.dart';
import '../widgets/connected_device_section.dart';
import '../widgets/no_connected_device_section.dart';
import '../widgets/printer_devices_list_section.dart';
import '../widgets/store_profile_section.dart';

typedef _C = AppColors;

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
    _loadStoreProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreProfile() async {
    final storage = di.sl<FlutterSecureStorage>();
    final name = await storage.read(key: 'STORE_NAME') ?? 'KASIRKU SEMBAKO';
    final address =
        await storage.read(key: 'STORE_ADDRESS') ?? 'Jl. Contoh No. 123, Kota';
    final phone = await storage.read(key: 'STORE_PHONE') ?? '08123456789';
    final logo = await storage.read(key: 'STORE_LOGO_PATH');

    setState(() {
      _nameController.text = name;
      _addressController.text = address;
      _phoneController.text = phone;
      _logoPath = logo;
    });
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final extensionName = p.extension(pickedFile.path);
        final fileName =
            'store_logo_${DateTime.now().millisecondsSinceEpoch}$extensionName';
        final localFile = await File(
          pickedFile.path,
        ).copy('${appDir.path}/$fileName');

        // Hapus file logo lama jika ada
        if (_logoPath != null) {
          final oldFile = File(_logoPath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }

        setState(() {
          _logoPath = localFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih logo: $e')));
      }
    }
  }

  Future<void> _removeLogo() async {
    try {
      if (_logoPath != null) {
        final file = File(_logoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      setState(() {
        _logoPath = null;
      });
    } catch (_) {
      setState(() {
        _logoPath = null;
      });
    }
  }

  Future<void> _saveStoreProfile() async {
    final storage = di.sl<FlutterSecureStorage>();
    await storage.write(key: 'STORE_NAME', value: _nameController.text.trim());
    await storage.write(
      key: 'STORE_ADDRESS',
      value: _addressController.text.trim(),
    );
    await storage.write(
      key: 'STORE_PHONE',
      value: _phoneController.text.trim(),
    );
    if (_logoPath != null) {
      await storage.write(key: 'STORE_LOGO_PATH', value: _logoPath!);
    } else {
      await storage.delete(key: 'STORE_LOGO_PATH');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil struk berhasil disimpan')),
      );
    }
  }

  Future<void> _requestPermissionsAndScan() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (mounted) {
      context.read<PrinterBloc>().add(ScanPrintersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.surface,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Printer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _C.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _requestPermissionsAndScan,
            tooltip: 'Pindai Perangkat',
          ),
        ],
      ),
      body: BlocConsumer<PrinterBloc, PrinterState>(
        listener: (context, state) {
          if (state is PrinterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _C.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is PrinterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _C.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PrinterLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _C.primary),
            );
          } else if (state is PrinterLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profil Cetak Struk
                  StoreProfileSection(
                    logoPath: _logoPath,
                    nameController: _nameController,
                    addressController: _addressController,
                    phoneController: _phoneController,
                    onPickLogo: _pickLogo,
                    onRemoveLogo: _removeLogo,
                    onSaveProfile: _saveStoreProfile,
                  ),
                  const SizedBox(height: 24),

                  // 2. Perangkat Terhubung
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      'Perangkat Terhubung',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _C.textSecondary,
                      ),
                    ),
                  ),
                  if (state.connectedMacAddress != null)
                    ConnectedDeviceSection(
                      macAddress: state.connectedMacAddress!,
                      onPrintTest: () =>
                          context.read<PrinterBloc>().add(PrintTestEvent()),
                      onDisconnect: () => context.read<PrinterBloc>().add(
                        DisconnectPrinterEvent(),
                      ),
                    )
                  else
                    const NoConnectedDeviceSection(),
                  const SizedBox(height: 24),

                  // 3. Daftar Printer
                  PrinterDevicesListSection(
                    devices: state.devices,
                    connectedMacAddress: state.connectedMacAddress,
                    onConnect: (mac) => context.read<PrinterBloc>().add(
                      ConnectPrinterEvent(mac),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
