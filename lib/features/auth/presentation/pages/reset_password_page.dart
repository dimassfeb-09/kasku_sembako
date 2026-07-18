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

class ResetPasswordPage extends StatefulWidget {
  final String resetToken;

  const ResetPasswordPage({super.key, required this.resetToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: SafeArea(
        child: BlocListener<PasswordResetBloc, PasswordResetState>(
          listener: (context, state) {
            if (state is PasswordResetSuccess) {
              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password berhasil diubah'),
                  backgroundColor: _C.success,
                ),
              );
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
                  Icon(
                    RemixIcons.lock_password_line,
                    size: 48,
                    color: _C.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Buat Password Baru',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Password minimal 8 karakter.',
                    style: TextStyle(fontSize: 14, color: _C.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppInput(
                    label: 'Password Baru',
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
                    label: 'Konfirmasi Password',
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    prefixIcon: RemixIcons.lock_2_line,
                    hintText: 'Ulangi password baru',
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
                  const SizedBox(height: 32),
                  BlocBuilder<PasswordResetBloc, PasswordResetState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Simpan Password',
                        isLoading: state is PasswordResetLoading,
                        onPressed: () {
                          final password = _passwordController.text;
                          final confirm = _confirmController.text;
                          if (password.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password minimal 8 karakter'),
                                backgroundColor: _C.error,
                              ),
                            );
                            return;
                          }
                          if (password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password tidak cocok'),
                                backgroundColor: _C.error,
                              ),
                            );
                            return;
                          }
                          context.read<PasswordResetBloc>().add(
                            ResetPasswordSubmitted(widget.resetToken, password),
                          );
                        },
                      );
                    },
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
