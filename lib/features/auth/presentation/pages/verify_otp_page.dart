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

class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: SafeArea(
        child: BlocListener<PasswordResetBloc, PasswordResetState>(
          listener: (context, state) {
            if (state is OtpVerified) {
              context.push('/reset-password', extra: state.resetToken);
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
                    RemixIcons.shield_keyhole_line,
                    size: 48,
                    color: _C.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verifikasi OTP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan kode OTP 6 digit yang dikirim\nke ${widget.email}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _C.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppInput(
                    label: 'Kode OTP',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: RemixIcons.key_2_line,
                    hintText: '123456',
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<PasswordResetBloc, PasswordResetState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Verifikasi',
                        isLoading: state is PasswordResetLoading,
                        onPressed: () {
                          final otp = _otpController.text.trim();
                          if (otp.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode OTP harus 6 digit'),
                                backgroundColor: _C.error,
                              ),
                            );
                            return;
                          }
                          context.read<PasswordResetBloc>().add(
                            VerifyOtpSubmitted(widget.email, otp),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      context.read<PasswordResetBloc>().add(
                        ForgotPasswordSubmitted(widget.email),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kode OTP baru telah dikirim'),
                          backgroundColor: _C.primary,
                        ),
                      );
                    },
                    child: const Text(
                      'Kirim ulang OTP',
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
