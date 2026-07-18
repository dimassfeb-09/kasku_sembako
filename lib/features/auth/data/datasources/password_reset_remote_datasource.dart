import 'package:dio/dio.dart';
import '../../../../core/network/api_error_mapper.dart';

abstract class PasswordResetRemoteDataSource {
  Future<void> forgotPassword(String email);
  Future<String> verifyOtp(String email, String otpCode);
  Future<void> resetPassword(String resetToken, String newPassword);
}

class PasswordResetRemoteDataSourceImpl
    implements PasswordResetRemoteDataSource {
  final Dio dio;

  PasswordResetRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<String> verifyOtp(String email, String otpCode) async {
    try {
      final response = await dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otpCode': otpCode},
      );
      return response.data['resetToken'] as String;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      await dio.post(
        '/auth/reset-password',
        data: {'resetToken': resetToken, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) => mapDioException(
    e,
    codeMessages: const {
      'VALIDATION_FAILED': 'Permintaan tidak valid.',
      'OTP_INVALID': 'Kode OTP tidak valid atau kadaluwarsa.',
      'OTP_ALREADY_USED': 'Kode OTP sudah digunakan.',
      'RESET_TOKEN_INVALID': 'Token reset tidak valid atau kadaluwarsa.',
      'RATE_LIMITED': 'Terlalu banyak percobaan. Coba lagi beberapa saat.',
    },
  );
}
