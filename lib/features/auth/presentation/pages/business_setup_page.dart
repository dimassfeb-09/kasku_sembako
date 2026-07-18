import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../data/datasources/store_profile_remote_datasource.dart';

typedef _C = AppColors;

class BusinessSetupPage extends StatefulWidget {
  const BusinessSetupPage({super.key});

  @override
  State<BusinessSetupPage> createState() => _BusinessSetupPageState();
}

class _BusinessSetupPageState extends State<BusinessSetupPage> {
  final _ownerController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailBusinessController = TextEditingController();
  String _selectedCategory = '';
  bool _isSaving = false;

  static const List<String> _categories = [
    'Toko Kelontong',
    'Minimarket',
    'Supermarket',
    'Warung Makan',
    'Restoran',
    'Toko Pakaian',
    'Toko Elektronik',
    'Toko Obat / Apotek',
    'Toko Pertanian',
    'Toko Bangunan',
    'Jasa / Servis',
    'Lainnya',
  ];

  @override
  void dispose() {
    _ownerController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailBusinessController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_ownerController.text.trim().isEmpty) {
      _showError('Nama owner harus diisi');
      return false;
    }
    if (_businessController.text.trim().isEmpty) {
      _showError('Nama bisnis harus diisi');
      return false;
    }
    if (_selectedCategory.isEmpty) {
      _showError('Kategori bisnis harus dipilih');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Nomor telepon harus diisi');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError('Alamat bisnis harus diisi');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _C.error));
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _isSaving = true);

    try {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: 'STORE_OWNER',
        value: _ownerController.text.trim(),
      );
      await storage.write(
        key: 'STORE_NAME',
        value: _businessController.text.trim(),
      );
      await storage.write(key: 'STORE_CATEGORY', value: _selectedCategory);
      await storage.write(
        key: 'STORE_PHONE',
        value: _phoneController.text.trim(),
      );
      await storage.write(
        key: 'STORE_ADDRESS',
        value: _addressController.text.trim(),
      );
      await storage.write(
        key: 'STORE_EMAIL',
        value: _emailBusinessController.text.trim(),
      );
      await storage.write(
        key: AppConstants.isBusinessSetupComplete,
        value: 'true',
      );

      final token = await storage.read(key: 'USER_SESSION_KEY');
      if (token != null) {
        final profile = StoreProfileModel(
          ownerName: _ownerController.text.trim(),
          businessName: _businessController.text.trim(),
          businessCategory: _selectedCategory,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          businessEmail: _emailBusinessController.text.trim(),
        );
        try {
          final dio = buildDio(storage);
          await StoreProfileRemoteDataSourceImpl(dio: dio).save(profile);
        } catch (_) {}
      }

      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Lengkapi Bisnis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Data Bisnis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lengkapi informasi bisnis Anda untuk mulai menggunakan KasirKu.',
              style: TextStyle(fontSize: 14, color: _C.textSecondary),
            ),
            const SizedBox(height: 32),
            AppInput(
              label: 'Nama Owner',
              controller: _ownerController,
              prefixIcon: RemixIcons.user_3_line,
              hintText: 'Nama lengkap pemilik',
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Nama Bisnis',
              controller: _businessController,
              prefixIcon: RemixIcons.store_2_line,
              hintText: 'Nama toko atau bisnis',
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KATEGORI BISNIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _C.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory.isEmpty
                      ? null
                      : _selectedCategory,
                  hint: Text(
                    'Pilih kategori',
                    style: TextStyle(fontSize: 13, color: _C.textMuted),
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v ?? ''),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      RemixIcons.price_tag_3_line,
                      size: 18,
                      color: _C.textSecondary,
                    ),
                    filled: true,
                    fillColor: _C.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _C.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _C.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _C.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Alamat Bisnis',
              controller: _addressController,
              maxLines: 3,
              prefixIcon: RemixIcons.map_pin_line,
              hintText: 'Jl. Contoh No. 123, Kota',
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Nomor Telepon',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: RemixIcons.phone_line,
              hintText: '08xxxxxxxxxx',
            ),
            const SizedBox(height: 20),
            AppInput(
              label: 'Email Bisnis',
              controller: _emailBusinessController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: RemixIcons.mail_line,
              hintText: 'bisnis@email.com',
            ),
            const SizedBox(height: 32),
            AppButton(text: 'Simpan', isLoading: _isSaving, onPressed: _save),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
