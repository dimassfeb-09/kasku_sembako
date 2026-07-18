import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/password_reset_usecases.dart';
import 'password_reset_event.dart';
import 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  PasswordResetBloc({
    required this.forgotPasswordUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
  }) : super(PasswordResetInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<VerifyOtpSubmitted>(_onVerifyOtp);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<PasswordResetReset>((_, emit) => emit(PasswordResetInitial()));
  }

  Future<void> _onForgotPassword(
    ForgotPasswordSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure.message)),
      (_) => emit(OtpSent(event.email)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());
    final result = await verifyOtpUseCase(event.email, event.otpCode);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure.message)),
      (token) => emit(OtpVerified(token)),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());
    final result = await resetPasswordUseCase(
      event.resetToken,
      event.newPassword,
    );
    result.fold(
      (failure) => emit(PasswordResetFailure(failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }
}
