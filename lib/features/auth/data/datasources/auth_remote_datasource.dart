import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String whatsapp,
  );
  Future<UserModel> login(String email, String password);
  Future<UserModel> me();
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Revokes the current refresh token server-side. Best-effort by design -
  /// callers should still clear local session state even if this fails
  /// (e.g. no network), since the user's intent to log out is local.
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({required this.dio, required this.secureStorage});

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String whatsapp,
  ) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'whatsapp': whatsapp,
        },
      );
      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String? ?? '';
      final userJson = response.data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      await _storeSession(token, refreshToken);

      return user;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    return _authRequest('/auth/login', email, password);
  }

  Future<UserModel> _authRequest(
    String path,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        path,
        data: {'email': email, 'password': password},
      );
      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String? ?? '';
      final userJson = response.data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      await _storeSession(token, refreshToken);

      return user;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<void> _storeSession(String token, String refreshToken) async {
    await secureStorage.write(key: AppConstants.sessionKey, value: token);
    await secureStorage.write(
      key: AppConstants.accountAccessTokenKey,
      value: token,
    );
    if (refreshToken.isNotEmpty) {
      await secureStorage.write(
        key: AppConstants.accountRefreshTokenKey,
        value: refreshToken,
      );
    }
  }

  @override
  Future<UserModel> me() async {
    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await dio.post(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await secureStorage.read(
      key: AppConstants.accountRefreshTokenKey,
    );
    if (refreshToken == null || refreshToken.isEmpty) return;

    try {
      await dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException {
      // Best-effort: the server-side token still expires on its own, and
      // the caller clears local session state regardless of this outcome.
    }
  }

  Exception _mapDioException(DioException e) => mapDioException(
    e,
    codeMessages: const {
      'VALIDATION_FAILED': 'Permintaan tidak valid.',
      'INVALID_CREDENTIALS': 'Email atau kata sandi salah.',
      'EMAIL_TAKEN': 'Email sudah terdaftar.',
      'TOKEN_MISSING': 'Sesi berakhir. Silakan masuk kembali.',
      'TOKEN_INVALID': 'Sesi berakhir. Silakan masuk kembali.',
      'REFRESH_TOKEN_INVALID': 'Sesi berakhir. Silakan masuk kembali.',
      'RATE_LIMITED': 'Terlalu banyak percobaan. Coba lagi beberapa saat.',
    },
  );
}
