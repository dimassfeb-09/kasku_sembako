import 'package:equatable/equatable.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordSubmitted extends PasswordResetEvent {
  final String email;

  const ForgotPasswordSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyOtpSubmitted extends PasswordResetEvent {
  final String email;
  final String otpCode;

  const VerifyOtpSubmitted(this.email, this.otpCode);

  @override
  List<Object?> get props => [email, otpCode];
}

class ResetPasswordSubmitted extends PasswordResetEvent {
  final String resetToken;
  final String newPassword;

  const ResetPasswordSubmitted(this.resetToken, this.newPassword);

  @override
  List<Object?> get props => [resetToken, newPassword];
}

class PasswordResetReset extends PasswordResetEvent {}
