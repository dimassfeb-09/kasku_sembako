import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart' as di;
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../data/datasources/store_profile_remote_datasource.dart';
import '../../domain/usecases/auth_usecases.dart';

typedef _C = AppColors;

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _ownerController = TextEditingController();
  final _businessController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailBusinessController = TextEditingController();
  String _selectedCategory = '';
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isChangingPassword = false;

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
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _businessController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailBusinessController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final storage = di.sl<FlutterSecureStorage>();
      _ownerController.text = await storage.read(key: 'STORE_OWNER') ?? '';
      _businessController.text = await storage.read(key: 'STORE_NAME') ?? '';
      _selectedCategory = await storage.read(key: 'STORE_CATEGORY') ?? '';
      _phoneController.text = await storage.read(key: 'STORE_PHONE') ?? '';
      _addressController.text = await storage.read(key: 'STORE_ADDRESS') ?? '';
      _emailBusinessController.text =
          await storage.read(key: 'STORE_EMAIL') ?? '';

      final token = await storage.read(key: 'USER_SESSION_KEY');
      if (token != null) {
        final dio = buildDio(storage);
        final remote = StoreProfileRemoteDataSourceImpl(dio: dio);
        final profile = await remote.get();
        if (profile != null && mounted) {
          _ownerController.text = profile.ownerName;
          _businessController.text = profile.businessName;
          _selectedCategory = profile.businessCategory;
          _phoneController.text = profile.phone;
          _addressController.text = profile.address;
          _emailBusinessController.text = profile.businessEmail;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  Future<void> _saveProfile() async {
    final owner = _ownerController.text.trim();
    final business = _businessController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (owner.isEmpty || business.isEmpty || phone.isEmpty || address.isEmpty) {
      _showError('Semua field harus diisi');
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      final storage = di.sl<FlutterSecureStorage>();
      await storage.write(key: 'STORE_OWNER', value: owner);
      await storage.write(key: 'STORE_NAME', value: business);
      await storage.write(key: 'STORE_CATEGORY', value: _selectedCategory);
      await storage.write(key: 'STORE_PHONE', value: phone);
      await storage.write(key: 'STORE_ADDRESS', value: address);
      await storage.write(
        key: 'STORE_EMAIL',
        value: _emailBusinessController.text.trim(),
      );

      final token = await storage.read(key: 'USER_SESSION_KEY');
      if (token != null) {
        final dio = buildDio(storage);
        final remote = StoreProfileRemoteDataSourceImpl(dio: dio);
        await remote.save(
          StoreProfileModel(
            ownerName: owner,
            businessName: business,
            businessCategory: _selectedCategory,
            phone: phone,
            address: address,
            businessEmail: _emailBusinessController.text.trim(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan'),
            backgroundColor: _C.success,
          ),
        );
      }
    } catch (e) {
      _showError('Gagal menyimpan profil');
    }
    if (mounted) setState(() => _isSavingProfile = false);
  }

  void _onChangePassword() {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      _showError('Password saat ini harus diisi');
      return;
    }
    if (newPass.length < 8) {
      _showError('Password baru minimal 8 karakter');
      return;
    }
    if (newPass != confirm) {
      _showError('Password baru tidak cocok');
      return;
    }

    setState(() => _isChangingPassword = true);
    di.sl<ChangePasswordUseCase>()(current, newPass).then((result) {
      if (!mounted) return;
      result.fold(
        (failure) {
          _showError(failure.message);
          setState(() => _isChangingPassword = false);
        },
        (_) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          setState(() => _isChangingPassword = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah'),
              backgroundColor: _C.success,
            ),
          );
        },
      );
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _C.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profil Bisnis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _C.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard('Informasi Bisnis', [
                    AppInput(
                      label: 'Nama Owner',
                      controller: _ownerController,
                      prefixIcon: RemixIcons.user_3_line,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Nama Bisnis',
                      controller: _businessController,
                      prefixIcon: RemixIcons.store_2_line,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Alamat',
                      controller: _addressController,
                      maxLines: 3,
                      prefixIcon: RemixIcons.map_pin_line,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Nomor Telepon',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: RemixIcons.phone_line,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Email Bisnis',
                      controller: _emailBusinessController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: RemixIcons.mail_line,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Simpan',
                      isLoading: _isSavingProfile,
                      onPressed: _saveProfile,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionCard('Ubah Password', [
                    AppInput(
                      label: 'Password Saat Ini',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      prefixIcon: RemixIcons.lock_line,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? RemixIcons.eye_off_line
                              : RemixIcons.eye_line,
                          color: _C.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Password Baru',
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      prefixIcon: RemixIcons.lock_line,
                      hintText: 'Minimal 8 karakter',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? RemixIcons.eye_off_line
                              : RemixIcons.eye_line,
                          color: _C.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Konfirmasi Password Baru',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      prefixIcon: RemixIcons.lock_2_line,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? RemixIcons.eye_off_line
                              : RemixIcons.eye_line,
                          color: _C.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Ubah Password',
                      isLoading: _isChangingPassword,
                      onPressed: _onChangePassword,
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
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
          initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
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
    );
  }
}
