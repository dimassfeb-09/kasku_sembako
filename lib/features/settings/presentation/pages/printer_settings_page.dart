import 'dart:async';
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
import '../../domain/entities/printer_config.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event_state.dart';
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
  String _paperSize = '58';
  bool _printLogo = true;
  bool _watermarkEnabled = true;
  PrinterLoaded? _lastLoaded;
  Timer? _debounce;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
    _loadStoreProfile();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameC.removeListener(_scheduleAutoSave);
    _addressC.removeListener(_scheduleAutoSave);
    _phoneC.removeListener(_scheduleAutoSave);
    _headerC.removeListener(_scheduleAutoSave);
    _footerC.removeListener(_scheduleAutoSave);
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
    final address =
        await storage.read(key: 'STORE_ADDRESS') ?? 'Jl. Contoh No. 123, Kota';
    final phone = await storage.read(key: 'STORE_PHONE') ?? '08123456789';
    final logo = await storage.read(key: 'STORE_LOGO_PATH');
    final header = await storage.read(key: 'RECEIPT_HEADER');
    final footer = await storage.read(key: 'RECEIPT_FOOTER');
    final paperSize = await storage.read(key: 'PAPER_SIZE') ?? '58';
    final printLogo = await storage.read(key: 'PRINT_LOGO') ?? 'true';
    final watermarkEnabled =
        await storage.read(key: 'WATERMARK_ENABLED') ?? 'true';

    if (!mounted) return;
    setState(() {
      _nameC.text = name;
      _addressC.text = address;
      _phoneC.text = phone;
      _logoPath = logo;
      _headerC.text = header ?? '';
      _footerC.text = footer ?? '';
      _paperSize = paperSize;
      _printLogo = printLogo == 'true';
      _watermarkEnabled = watermarkEnabled == 'true';
    });
    _nameC.addListener(_scheduleAutoSave);
    _addressC.addListener(_scheduleAutoSave);
    _phoneC.addListener(_scheduleAutoSave);
    _headerC.addListener(_scheduleAutoSave);
    _footerC.addListener(_scheduleAutoSave);
    _loaded = true;
  }

  Future<void> _pickLogo() async {
    if (!isProEntitled(context)) {
      await showProUpsell(context, fitur: 'Logo struk kustom');
      return;
    }
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
        if (_logoPath != null) {
          final oldFile = File(_logoPath!);
          if (await oldFile.exists()) await oldFile.delete();
        }
        setState(() => _logoPath = localFile.path);
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
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
    setState(() => _logoPath = null);
  }

  void _showAddPrinterDialog(BuildContext context, String mac) {
    final labelC = TextEditingController();
    String role = 'receipt';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Tambah Printer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mac,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: _C.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelC,
                decoration: InputDecoration(
                  labelText: 'Nama Printer',
                  hintText: 'contoh: Kasir, Dapur',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Peruntukan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'receipt',
                    label: Text('Struk', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: 'kitchen',
                    label: Text('Dapur', style: TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {role},
                onSelectionChanged: (v) => setDialogState(() {
                  role = v.first;
                }),
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<PrinterBloc>().add(
                  ConnectPrinterEvent(
                    mac,
                    label: labelC.text.trim(),
                    role: role,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tambah',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleAutoSave() {
    if (!_loaded) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _autoSave);
  }

  Future<void> _autoSave() async {
    final storage = di.sl<FlutterSecureStorage>();
    final pro = mounted && isProEntitled(context);
    await storage.write(key: 'STORE_NAME', value: _nameC.text.trim());
    await storage.write(key: 'STORE_ADDRESS', value: _addressC.text.trim());
    await storage.write(key: 'STORE_PHONE', value: _phoneC.text.trim());
    if (_logoPath != null) {
      await storage.write(key: 'STORE_LOGO_PATH', value: _logoPath!);
    }
    if (pro) {
      await storage.write(key: 'RECEIPT_HEADER', value: _headerC.text.trim());
      await storage.write(key: 'RECEIPT_FOOTER', value: _footerC.text.trim());
    }
  }

  void _saveSettings() {
    _debounce?.cancel();
    _autoSave();
    setState(() => _previewCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan printer berhasil disimpan')),
    );
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
          }
          if (state is PrinterLoaded) {
            _lastLoaded = state;
            return _buildContent(context, state);
          }
          if (_lastLoaded != null) {
            return _buildContent(context, _lastLoaded!);
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
          _HeroSection(
            bluetoothOn: state.bluetoothOn,
            onScan: _requestPermissionsAndScan,
          ),
          const SizedBox(height: 24),
          _SectionLabel(icon: RemixIcons.receipt_line, label: 'Profil Toko'),
          const SizedBox(height: 12),
          _StoreProfileCard(
            logoPath: _logoPath,
            nameC: _nameC,
            addressC: _addressC,
            phoneC: _phoneC,
            onPickLogo: _pickLogo,
            onRemoveLogo: _removeLogo,
          ),
          const SizedBox(height: 16),
          _PrintLogoTile(
            value: _printLogo,
            isPro: isPro,
            onChanged: (v) async {
              setState(() {
                _printLogo = v;
              });
              await di.sl<FlutterSecureStorage>().write(
                key: 'PRINT_LOGO',
                value: v.toString(),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionLabel(
            icon: RemixIcons.settings_4_line,
            label: 'Tampilan Struk',
          ),
          const SizedBox(height: 12),
          _PaperSizeCard(
            value: _paperSize,
            onChanged: (v) async {
              setState(() {
                _paperSize = v;
              });
              await di.sl<FlutterSecureStorage>().write(
                key: 'PAPER_SIZE',
                value: v,
              );
            },
          ),
          if (isPro) ...[
            const SizedBox(height: 16),
            _WatermarkTile(
              value: _watermarkEnabled,
              isPro: isPro,
              onChanged: (v) async {
                setState(() {
                  _watermarkEnabled = v;
                });
                await di.sl<FlutterSecureStorage>().write(
                  key: 'WATERMARK_ENABLED',
                  value: v.toString(),
                );
              },
            ),
          ],
          if (isPro) ...[
            const SizedBox(height: 24),
            _SectionLabel(icon: RemixIcons.text, label: 'Kustomisasi Teks'),
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
          _SectionLabel(
            icon: RemixIcons.bluetooth_line,
            label: 'Daftar Printer',
          ),
          const SizedBox(height: 12),
          _PrinterListCard(
            printers: state.printers,
            onTest: (mac) => context.read<PrinterBloc>().add(
              PrintTestEvent(macAddress: mac),
            ),
            onRemove: (mac) =>
                context.read<PrinterBloc>().add(RemovePrinterEvent(mac)),
          ),
          const SizedBox(height: 12),
          PrinterDevicesListSection(
            devices: state.devices,
            bluetoothOn: state.bluetoothOn,
            savedMacs: state.printers.map((p) => p.macAddress).toList(),
            onConnect: (mac) => _showAddPrinterDialog(context, mac),
            onScan: _requestPermissionsAndScan,
          ),
          const SizedBox(height: 16),
          AppButton(text: 'Simpan Pengaturan', onPressed: _saveSettings),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              RemixIcons.printer_line,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Printer Thermal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: bluetoothOn ? _C.success : _C.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bluetoothOn ? 'Bluetooth aktif' : 'Bluetooth tidak aktif',
                      style: TextStyle(
                        fontSize: 12,
                        color: bluetoothOn ? _C.success : _C.textMuted,
                      ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RemixIcons.refresh_line, size: 14, color: _C.primary),
                    SizedBox(width: 4),
                    Text(
                      'Coba lagi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.primary,
                      ),
                    ),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              RemixIcons.printer_line,
              color: Color(0xFFD97706),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kustomisasi Struk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Atur nama toko, alamat, logo, header, dan footer pada struk thermal.\n'
            'Fitur ini tersedia untuk pengguna Pro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: _C.textSecondary,
              height: 1.5,
            ),
          ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.textMuted,
            letterSpacing: 0.5,
          ),
        ),
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

  const _StoreProfileCard({
    required this.logoPath,
    required this.nameC,
    required this.addressC,
    required this.phoneC,
    required this.onPickLogo,
    required this.onRemoveLogo,
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _C.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: logoPath != null
                            ? _C.primary.withValues(alpha: 0.5)
                            : _C.border,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (logoPath != null && File(logoPath!).existsSync())
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(logoPath!),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                RemixIcons.image_add_line,
                                size: 24,
                                color: _C.textMuted,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Logo',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _C.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (logoPath != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              RemixIcons.delete_bin_line,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  logoPath != null
                      ? 'Ketuk untuk hapus logo'
                      : 'Ketuk untuk tambah logo',
                  style: TextStyle(
                    fontSize: 11,
                    color: logoPath != null ? _C.textMuted : _C.textMuted,
                  ),
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
                child: Text(
                  'Teks pada struk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
              ),
              if (!isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFE5A3)),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF995500),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ReceiptField(
            controller: headerC,
            label: 'Header',
            hint: 'Terima kasih telah berbelanja...',
            enabled: isPro,
          ),
          const SizedBox(height: 12),
          _ReceiptField(
            controller: footerC,
            label: 'Footer',
            hint: 'Barang yang sudah dibeli tidak dapat ditukar...',
            enabled: isPro,
          ),
        ],
      ),
    );
  }
}

// ─── Print Logo Toggle ────────────────────────────────────────────────────────

class _PrintLogoTile extends StatelessWidget {
  final bool value;
  final bool isPro;
  final ValueChanged<bool> onChanged;

  const _PrintLogoTile({
    required this.value,
    required this.isPro,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderLight),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: isPro ? onChanged : null,
        title: Row(
          children: [
            const Text(
              'Cetak Logo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (!isPro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFE5A3)),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF995500),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          isPro
              ? 'Tampilkan logo toko di struk'
              : 'Upload logo tersedia untuk pengguna Pro',
          style: const TextStyle(fontSize: 12, color: _C.textSecondary),
        ),
        activeThumbColor: _C.primary,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

// ─── Paper Size ───────────────────────────────────────────────────────────────

class _PaperSizeCard extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PaperSizeCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ukuran Kertas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Pilih lebar kertas thermal',
            style: TextStyle(fontSize: 12, color: _C.textSecondary),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: '58',
                label: Text('58 mm', style: TextStyle(fontSize: 13)),
              ),
              ButtonSegment(
                value: '80',
                label: Text('80 mm', style: TextStyle(fontSize: 13)),
              ),
            ],
            selected: {value},
            onSelectionChanged: (v) => onChanged(v.first),
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Watermark Toggle ─────────────────────────────────────────────────────────

class _WatermarkTile extends StatelessWidget {
  final bool value;
  final bool isPro;
  final ValueChanged<bool> onChanged;

  const _WatermarkTile({
    required this.value,
    required this.isPro,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderLight),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: isPro ? onChanged : null,
        title: Row(
          children: [
            const Text(
              'Watermark Kasirku',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (!isPro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFE5A3)),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF995500),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          isPro
              ? 'Tampilkan watermark "Dicetak via Kasirku" di struk'
              : 'Kustom watermark hanya untuk pengguna Pro',
          style: const TextStyle(fontSize: 12, color: _C.textSecondary),
        ),
        activeThumbColor: _C.primary,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

class _PrinterListCard extends StatelessWidget {
  final List<PrinterConfig> printers;
  final void Function(String mac) onTest;
  final void Function(String mac) onRemove;

  const _PrinterListCard({
    required this.printers,
    required this.onTest,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(RemixIcons.printer_line, size: 16, color: _C.textSecondary),
              SizedBox(width: 8),
              Text(
                'Printer Tersimpan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (printers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada printer',
                  style: TextStyle(fontSize: 13, color: _C.textSecondary),
                ),
              ),
            )
          else
            ...printers.map((p) => _printerItem(context, p)),
        ],
      ),
    );
  }

  Widget _printerItem(BuildContext context, PrinterConfig p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.role == 'kitchen'
                  ? const Color(0xFFFFF3D6)
                  : _C.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              p.role == 'kitchen'
                  ? RemixIcons.restaurant_line
                  : RemixIcons.receipt_line,
              size: 18,
              color: p.role == 'kitchen' ? const Color(0xFFD97706) : _C.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.label.isNotEmpty
                      ? p.label
                      : 'Printer ${p.role == 'kitchen' ? 'Dapur' : 'Kasir'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.macAddress,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: _C.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: p.role == 'kitchen'
                  ? const Color(0xFFFFF3D6)
                  : _C.primaryLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              p.role == 'kitchen' ? 'Dapur' : 'Struk',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: p.role == 'kitchen'
                    ? const Color(0xFFD97706)
                    : _C.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onTest(p.macAddress),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                RemixIcons.play_line,
                size: 14,
                color: _C.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onRemove(p.macAddress),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _C.dangerLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                RemixIcons.delete_bin_line,
                size: 14,
                color: _C.danger,
              ),
            ),
          ),
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

  const _ReceiptField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? _C.textSecondary : _C.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 2,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? _C.textPrimary : _C.textMuted,
          ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: enabled ? _C.white : _C.background,
          ),
        ),
      ],
    );
  }
}
