import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

typedef _C = AppColors;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _whatsappController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama lengkap harus diisi');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Email harus diisi');
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _showError('Format email tidak valid');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('Kata sandi minimal 8 karakter');
      return false;
    }
    if (_passwordController.text != _confirmController.text) {
      _showError('Kata sandi tidak cocok');
      return false;
    }
    if (_whatsappController.text.trim().isEmpty) {
      _showError('Nomor WhatsApp harus diisi');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _C.error));
  }

  void _onRegister() {
    if (!_validate()) return;
    context.read<AuthBloc>().add(
      RegisterSubmittedEvent(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _whatsappController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/business-setup');
          } else if (state is AuthError) {
            _showError(state.message);
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Buat akun KasirKu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daftarkan bisnis Anda untuk menyimpan data dengan aman.',
                    style: TextStyle(fontSize: 14, color: _C.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  AppInput(
                    label: 'Nama Lengkap / Nama Bisnis',
                    controller: _nameController,
                    prefixIcon: RemixIcons.user_3_line,
                    hintText: 'Contoh: Toko Sembako Makmur',
                  ),
                  const SizedBox(height: 20),
                  AppInput(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: RemixIcons.mail_line,
                    hintText: 'nama@tokoanda.com',
                  ),
                  const SizedBox(height: 20),
                  AppInput(
                    label: 'Kata Sandi',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: RemixIcons.lock_line,
                    hintText: 'Minimal 8 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? RemixIcons.eye_off_line
                            : RemixIcons.eye_line,
                        color: _C.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppInput(
                    label: 'Konfirmasi Kata Sandi',
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    prefixIcon: RemixIcons.lock_2_line,
                    hintText: 'Ulangi kata sandi',
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
                  AppInput(
                    label: 'WhatsApp',
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: RemixIcons.whatsapp_line,
                    hintText: '08xxxxxxxxxx',
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Daftar',
                        isLoading: state is AuthLoading,
                        onPressed: _onRegister,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(fontSize: 13, color: _C.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
