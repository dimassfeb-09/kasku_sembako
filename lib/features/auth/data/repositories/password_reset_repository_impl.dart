import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/password_reset_repository.dart';
import '../datasources/password_reset_remote_datasource.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetRemoteDataSource remoteDataSource;

  PasswordResetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengirim OTP: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp(
    String email,
    String otpCode,
  ) async {
    try {
      final token = await remoteDataSource.verifyOtp(email, otpCode);
      return Right(token);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal verifikasi OTP: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String resetToken,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(resetToken, newPassword);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal reset password: ${e.toString()}'));
    }
  }
}
