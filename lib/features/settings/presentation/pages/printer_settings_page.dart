import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event_state.dart';
import '../widgets/connected_device_section.dart';
import '../widgets/no_connected_device_section.dart';
import '../widgets/printer_devices_list_section.dart';
import '../widgets/receipt_preview_card.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';

typedef _C = AppColors;

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final _nameC = TextEditingController();
  final _addressC = TextEditingController();
  final _phoneC = TextEditingController();
  final _headerC = TextEditingController();
  final _footerC = TextEditingController();
  String? _logoPath;
  int _previewCount = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
    _loadStoreProfile();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _addressC.dispose();
    _phoneC.dispose();
    _headerC.dispose();
    _footerC.dispose();
    super.dispose();
  }

  Future<void> _loadStoreProfile() async {
    final storage = di.sl<FlutterSecureStorage>();
    final name = await storage.read(key: 'STORE_NAME') ?? 'KASIRKU SEMBAKO';
    final address = await storage.read(key: 'STORE_ADDRESS') ?? 'Jl. Contoh No. 123, Kota';
    final phone = await storage.read(key: 'STORE_PHONE') ?? '08123456789';
    final logo = await storage.read(key: 'STORE_LOGO_PATH');
    final header = await storage.read(key: 'RECEIPT_HEADER');
    final footer = await storage.read(key: 'RECEIPT_FOOTER');

    setState(() {
      _nameC.text = name;
      _addressC.text = address;
      _phoneC.text = phone;
      _logoPath = logo;
      _headerC.text = header ?? '';
      _footerC.text = footer ?? '';
    });
  }

  Future<void> _pickLogo() async {
    if (!isProEntitled(context)) {
      await showProUpsell(context, fitur: 'Logo struk kustom');
      return;
    }
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final extensionName = p.extension(pickedFile.path);
        final fileName = 'store_logo_${DateTime.now().millisecondsSinceEpoch}$extensionName';
        final localFile = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        if (_logoPath != null) {
          final oldFile = File(_logoPath!);
          if (await oldFile.exists()) await oldFile.delete();
        }
        setState(() => _logoPath = localFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih logo: $e')));
      }
    }
  }

  Future<void> _removeLogo() async {
    try {
      if (_logoPath != null) {
        final file = File(_logoPath!);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
    setState(() => _logoPath = null);
  }

  Future<void> _saveStoreProfile() async {
    final storage = di.sl<FlutterSecureStorage>();
    await storage.write(key: 'STORE_NAME', value: _nameC.text.trim());
    await storage.write(key: 'STORE_ADDRESS', value: _addressC.text.trim());
    await storage.write(key: 'STORE_PHONE', value: _phoneC.text.trim());
    if (_logoPath != null) {
      await storage.write(key: 'STORE_LOGO_PATH', value: _logoPath!);
    } else {
      await storage.delete(key: 'STORE_LOGO_PATH');
    }

    if (isProEntitled(context)) {
      await storage.write(key: 'RECEIPT_HEADER', value: _headerC.text.trim());
      await storage.write(key: 'RECEIPT_FOOTER', value: _footerC.text.trim());
    }

    if (mounted) {
      setState(() => _previewCount++);
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
      backgroundColor: _C.background,
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        backgroundColor: _C.white,
        surfaceTintColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(RemixIcons.refresh_line),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is PrinterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _C.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PrinterLoading) {
            return const Center(child: CircularProgressIndicator(color: _C.primary));
          }
          if (state is PrinterLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrinterLoaded state) {
    final isPro = isProEntitled(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection(bluetoothOn: state.bluetoothOn, onScan: _requestPermissionsAndScan),
          if (isPro) ...[
            const SizedBox(height: 24),
            _SectionLabel(icon: RemixIcons.receipt_line, label: 'Profil Struk'),
            const SizedBox(height: 12),
            _StoreProfileCard(
              logoPath: _logoPath,
              nameC: _nameC,
              addressC: _addressC,
              phoneC: _phoneC,
              onPickLogo: _pickLogo,
              onRemoveLogo: _removeLogo,
              onSaveProfile: _saveStoreProfile,
            ),
            const SizedBox(height: 24),
            _SectionLabel(icon: RemixIcons.text, label: 'Kustomisasi'),
            const SizedBox(height: 12),
            _HeaderFooterCard(headerC: _headerC, footerC: _footerC),
            const SizedBox(height: 24),
            _SectionLabel(icon: RemixIcons.eye_line, label: 'Pratinjau Struk'),
            const SizedBox(height: 12),
            ReceiptPreviewCard(key: ValueKey(_previewCount)),
          ] else ...[
            const SizedBox(height: 24),
            _ProUpsellCard(),
          ],
          const SizedBox(height: 24),
          _SectionLabel(icon: RemixIcons.bluetooth_line, label: 'Koneksi Printer'),
          const SizedBox(height: 12),
          if (state.connectedMacAddress != null)
            ConnectedDeviceSection(
              macAddress: state.connectedMacAddress!,
              onPrintTest: () => context.read<PrinterBloc>().add(PrintTestEvent()),
              onDisconnect: () => context.read<PrinterBloc>().add(DisconnectPrinterEvent()),
            )
          else
            const NoConnectedDeviceSection(),
          const SizedBox(height: 12),
          PrinterDevicesListSection(
            devices: state.devices,
            bluetoothOn: state.bluetoothOn,
            connectedMacAddress: state.connectedMacAddress,
            onConnect: (mac) => context.read<PrinterBloc>().add(ConnectPrinterEvent(mac)),
            onScan: _requestPermissionsAndScan,
          ),
        ],
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool bluetoothOn;
  final VoidCallback onScan;
  const _HeroSection({required this.bluetoothOn, required this.onScan});

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
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(RemixIcons.printer_line, color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Printer Thermal',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: bluetoothOn ? _C.success : _C.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bluetoothOn ? 'Bluetooth aktif' : 'Bluetooth tidak aktif',
                      style: TextStyle(fontSize: 12, color: bluetoothOn ? _C.success : _C.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!bluetoothOn)
            GestureDetector(
              onTap: onScan,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RemixIcons.refresh_line, size: 14, color: _C.primary),
                    SizedBox(width: 4),
                    Text('Coba lagi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.primary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Pro Upsell ───────────────────────────────────────────────────────────────

class _ProUpsellCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE5A3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(RemixIcons.printer_line, color: Color(0xFFD97706), size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Kustomisasi Struk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Atur nama toko, alamat, logo, header, dan footer pada struk thermal.\n'
            'Fitur ini tersedia untuk pengguna Pro.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: _C.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          AppButton(
            text: 'Upgrade ke Pro',
            onPressed: () => context.push('/subscription/upgrade'),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _C.textMuted),
        const SizedBox(width: 8),
        Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textMuted, letterSpacing: 0.5)),
      ],
    );
  }
}

// ─── Store Profile ───────────────────────────────────────────────────────────

class _StoreProfileCard extends StatelessWidget {
  final String? logoPath;
  final TextEditingController nameC;
  final TextEditingController addressC;
  final TextEditingController phoneC;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;
  final VoidCallback onSaveProfile;

  const _StoreProfileCard({
    required this.logoPath,
    required this.nameC,
    required this.addressC,
    required this.phoneC,
    required this.onPickLogo,
    required this.onRemoveLogo,
    required this.onSaveProfile,
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
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: logoPath != null ? onRemoveLogo : onPickLogo,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: _C.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: logoPath != null ? _C.primary.withValues(alpha: 0.5) : _C.border,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (logoPath != null && File(logoPath!).existsSync())
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(File(logoPath!), width: 80, height: 80, fit: BoxFit.cover),
                          )
                        else
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(RemixIcons.image_add_line, size: 24, color: _C.textMuted),
                              SizedBox(height: 4),
                              Text('Logo', style: TextStyle(fontSize: 10, color: _C.textMuted, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        if (logoPath != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(RemixIcons.delete_bin_line, color: Colors.white, size: 24),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  logoPath != null ? 'Ketuk untuk hapus logo' : 'Ketuk untuk tambah logo',
                  style: TextStyle(fontSize: 11, color: logoPath != null ? _C.textMuted : _C.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppInput(
            controller: nameC,
            label: 'Nama Toko',
            hintText: 'Kasirku Sembako',
            prefixIcon: Icons.store_rounded,
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: addressC,
            label: 'Alamat Toko',
            hintText: 'Jl. Merdeka No. 45',
            prefixIcon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: phoneC,
            label: 'Nomor Telepon',
            hintText: '08123456789',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          AppButton(text: 'Simpan Profil Struk', onPressed: onSaveProfile),
        ],
      ),
    );
  }
}

// ─── Header/Footer ───────────────────────────────────────────────────────────

class _HeaderFooterCard extends StatelessWidget {
  final TextEditingController headerC;
  final TextEditingController footerC;

  const _HeaderFooterCard({required this.headerC, required this.footerC});

  @override
  Widget build(BuildContext context) {
    final isPro = isProEntitled(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Teks pada struk',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary)),
              ),
              if (!isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFE5A3)),
                  ),
                  child: const Text('PRO', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF995500))),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ReceiptField(controller: headerC, label: 'Header', hint: 'Terima kasih telah berbelanja...', enabled: isPro),
          const SizedBox(height: 12),
          _ReceiptField(controller: footerC, label: 'Footer', hint: 'Barang yang sudah dibeli tidak dapat ditukar...', enabled: isPro),
        ],
      ),
    );
  }
}

class _ReceiptField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;

  const _ReceiptField({required this.controller, required this.label, required this.hint, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: enabled ? _C.textSecondary : _C.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 2,
          style: TextStyle(fontSize: 13, color: enabled ? _C.textPrimary : _C.textMuted),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: _C.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: enabled ? _C.white : _C.background,
          ),
        ),
      ],
    );
  }
}
