import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/password_reset_repository.dart';

class ForgotPasswordUseCase {
  final PasswordResetRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}

class VerifyOtpUseCase {
  final PasswordResetRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String email, String otpCode) async {
    return await repository.verifyOtp(email, otpCode);
  }
}

class ResetPasswordUseCase {
  final PasswordResetRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String resetToken,
    String newPassword,
  ) async {
    return await repository.resetPassword(resetToken, newPassword);
  }
}
