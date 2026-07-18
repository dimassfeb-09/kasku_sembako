import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../bloc/password_reset_bloc.dart';
import '../bloc/password_reset_event.dart';
import '../bloc/password_reset_state.dart';

typedef _C = AppColors;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: SafeArea(
        child: BlocListener<PasswordResetBloc, PasswordResetState>(
          listener: (context, state) {
            if (state is OtpSent) {
              context.push('/verify-otp', extra: state.email);
            } else if (state is PasswordResetFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: _C.error,
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Icon(RemixIcons.lock_line, size: 48, color: _C.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Lupa Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan email terdaftar, kami akan\nmengirimkan kode OTP.',
                    style: TextStyle(fontSize: 14, color: _C.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppInput(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: RemixIcons.mail_line,
                    hintText: 'nama@tokoanda.com',
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<PasswordResetBloc, PasswordResetState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Kirim OTP',
                        isLoading: state is PasswordResetLoading,
                        onPressed: () {
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email harus diisi'),
                                backgroundColor: _C.error,
                              ),
                            );
                            return;
                          }
                          context.read<PasswordResetBloc>().add(
                            ForgotPasswordSubmitted(email),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      'Kembali ke Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.primary,
                      ),
                    ),
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
