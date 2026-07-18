import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class AccountRegisterPage extends StatefulWidget {
  const AccountRegisterPage({super.key});

  @override
  State<AccountRegisterPage> createState() => _AccountRegisterPageState();
}

class _AccountRegisterPageState extends State<AccountRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _whatsappController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final whatsapp = _whatsappController.text.trim();

    if (name.isEmpty) {
      _showError('Nama lengkap harus diisi');
      return;
    }
    if (email.isEmpty) {
      _showError('Email harus diisi');
      return;
    }
    if (password.length < 8) {
      _showError('Kata sandi minimal 8 karakter');
      return;
    }
    if (whatsapp.isEmpty) {
      _showError('Nomor WhatsApp harus diisi');
      return;
    }

    context.read<AccountBloc>().add(
      RegisterSubmittedEvent(name, email, password, whatsapp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Buat Akun Toko'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountSignedIn) {
            context.pop();
          } else if (state is AccountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Daftar Akun Toko',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Akun ini mewakili toko Anda untuk berlangganan Pro dan cadangan cloud.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  AppInput(
                    label: 'Nama Lengkap / Nama Bisnis',
                    controller: _nameController,
                    prefixIcon: Icons.storefront_outlined,
                    hintText: 'Contoh: Toko Sembako Makmur',
                  ),
                  const SizedBox(height: 18),
                  AppInput(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    hintText: 'nama@tokoanda.com',
                  ),
                  const SizedBox(height: 18),
                  AppInput(
                    label: 'Kata Sandi',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    hintText: 'Minimal 8 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppInput(
                    label: 'WhatsApp',
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.chat_outlined,
                    hintText: '08xxxxxxxxxx',
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AccountBloc, AccountState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Daftar',
                        isLoading: state is AccountLoading,
                        onPressed: _onRegister,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
