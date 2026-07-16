import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi tidak boleh kosong')),
      );
      return;
    }
    context.read<AuthBloc>().add(LoginSubmittedEvent(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun toko Anda untuk melanjutkan.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 40),
              AppInput(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline,
                hintText: 'nama@tokoanda.com',
              ),
              const SizedBox(height: 20),
              AppInput(
                label: 'Kata Sandi',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                hintText: 'Masukkan kata sandi',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AppButton(
                    text: 'Masuk',
                    isLoading: state is AuthLoading,
                    onPressed: _onLogin,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9488),
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
    );
  }
}
