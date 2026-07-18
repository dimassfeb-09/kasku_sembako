import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/account_model.dart';

abstract class AccountRemoteDataSource {
  /// [name] and [whatsapp] are required by POST /auth/register even though
  /// they aren't part of [AccountModel] - the endpoint is shared with the
  /// auth feature, which does surface them.
  Future<AccountModel> register(
    String name,
    String email,
    String password,
    String whatsapp,
  );
  Future<AccountModel> login(String email, String password);
  Future<AccountModel> me();

  /// Revokes the current refresh token server-side. Best-effort by design -
  /// callers should still clear local session state even if this fails
  /// (e.g. no network), since the user's intent to log out is local.
  Future<void> logout();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AccountRemoteDataSourceImpl({required this.dio, required this.secureStorage});

  @override
  Future<AccountModel> register(
    String name,
    String email,
    String password,
    String whatsapp,
  ) async {
    return _authRequest('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'whatsapp': whatsapp,
    });
  }

  @override
  Future<AccountModel> login(String email, String password) async {
    return _authRequest('/auth/login', {'email': email, 'password': password});
  }

  Future<AccountModel> _authRequest(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.post(path, data: body);
      final token = response.data['token'] as String;
      final refreshToken = response.data['refreshToken'] as String? ?? '';
      final userJson = response.data['user'] as Map<String, dynamic>;
      final account = AccountModel.fromJson(userJson);

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
      await secureStorage.write(
        key: AppConstants.accountIdKey,
        value: account.id,
      );
      await secureStorage.write(
        key: AppConstants.accountEmailKey,
        value: account.email,
      );
      await secureStorage.write(
        key: AppConstants.accountCreatedAtKey,
        value: account.createdAt.toIso8601String(),
      );

      return account;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<AccountModel> me() async {
    try {
      final response = await dio.get('/auth/me');
      return AccountModel.fromJson(response.data as Map<String, dynamic>);
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
      'RATE_LIMITED': 'Terlalu banyak percobaan. Coba lagi beberapa saat.',
    },
  );
}
