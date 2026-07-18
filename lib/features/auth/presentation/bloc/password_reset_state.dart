import 'package:equatable/equatable.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class OtpSent extends PasswordResetState {
  final String email;

  const OtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

class OtpVerified extends PasswordResetState {
  final String resetToken;

  const OtpVerified(this.resetToken);

  @override
  List<Object?> get props => [resetToken];
}

class PasswordResetSuccess extends PasswordResetState {}

class PasswordResetFailure extends PasswordResetState {
  final String message;

  const PasswordResetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
