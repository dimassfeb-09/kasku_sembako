import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class RegisterStepAccount extends StatefulWidget {
  final TextEditingController ownerController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  const RegisterStepAccount({
    super.key,
    required this.ownerController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
  });

  @override
  State<RegisterStepAccount> createState() => _RegisterStepAccountState();
}

class _RegisterStepAccountState extends State<RegisterStepAccount> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Data Pemilik',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi data pemilik untuk memulai.',
            style: TextStyle(fontSize: 14, color: _C.textSecondary),
          ),
          const SizedBox(height: 32),
          AppInput(
            label: 'Nama Pemilik',
            controller: widget.ownerController,
            prefixIcon: RemixIcons.user_3_line,
            hintText: 'Contoh: Dimas Firmansyah',
          ),
          const SizedBox(height: 20),
          AppInput(
            label: 'Email',
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: RemixIcons.mail_line,
            hintText: 'nama@tokoanda.com',
          ),
          const SizedBox(height: 20),
          AppInput(
            label: 'Kata Sandi',
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            prefixIcon: RemixIcons.lock_line,
            hintText: 'Minimal 8 karakter',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                color: _C.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          AppInput(
            label: 'Konfirmasi Kata Sandi',
            controller: widget.confirmController,
            obscureText: _obscureConfirm,
            prefixIcon: RemixIcons.lock_2_line,
            hintText: 'Ulangi kata sandi',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                color: _C.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
