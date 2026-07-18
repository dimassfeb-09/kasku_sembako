import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class QrisSettingPage extends StatefulWidget {
  const QrisSettingPage({super.key});

  @override
  State<QrisSettingPage> createState() => _QrisSettingPageState();
}

class _QrisSettingPageState extends State<QrisSettingPage> {
  final _secureStorage = const FlutterSecureStorage();
  final _picker = ImagePicker();

  String? _imagePath;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final path = await _secureStorage.read(key: AppConstants.qrisImagePathKey);
    if (!mounted) return;
    setState(() {
      _imagePath = path;
      _loaded = true;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return;
    await _secureStorage.write(
      key: AppConstants.qrisImagePathKey,
      value: image.path,
    );
    if (!mounted) return;
    setState(() => _imagePath = image.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gambar QRIS berhasil disimpan')),
    );
  }

  Future<void> _removeImage() async {
    await _secureStorage.delete(key: AppConstants.qrisImagePathKey);
    if (!mounted) return;
    setState(() => _imagePath = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gambar QRIS dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Pengaturan QRIS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _C.textPrimary,
          ),
        ),
      ),
      body: _loaded
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _C.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              RemixIcons.qr_code_line,
                              size: 24,
                              color: _C.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QRIS Pembayaran',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _C.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Pelanggan scan QR ini untuk bayar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _C.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_imagePath != null && File(_imagePath!).existsSync())
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _C.borderLight),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Image.file(
                                File(_imagePath!),
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                              const Divider(height: 1),
                              InkWell(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: _C.danger,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Hapus Gambar',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _C.danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: _C.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _C.borderLight,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                RemixIcons.qr_code_line,
                                size: 48,
                                color: _C.textMuted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada gambar QRIS',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _C.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_rounded, size: 18),
                        label: const Text(
                          'Pilih Gambar dari Galeri',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: _C.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
