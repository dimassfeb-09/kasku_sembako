import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class PasswordResetRepository {
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, String>> verifyOtp(String email, String otpCode);
  Future<Either<Failure, void>> resetPassword(
    String resetToken,
    String newPassword,
  );
}
