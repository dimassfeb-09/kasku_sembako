import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/account_model.dart';

abstract class AccountRemoteDataSource {
  Future<AccountModel> register(String email, String password);
  Future<AccountModel> login(String email, String password);
  Future<AccountModel> me();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AccountRemoteDataSourceImpl({required this.dio, required this.secureStorage});

  @override
  Future<AccountModel> register(String email, String password) async {
    return _authRequest('/auth/register', email, password);
  }

  @override
  Future<AccountModel> login(String email, String password) async {
    return _authRequest('/auth/login', email, password);
  }

  Future<AccountModel> _authRequest(
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
      final userJson = response.data['user'] as Map<String, dynamic>;
      final account = AccountModel.fromJson(userJson);

      await secureStorage.write(
        key: AppConstants.accountAccessTokenKey,
        value: token,
      );
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

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Tidak dapat terhubung ke server.');
    }
    final status = e.response?.statusCode;
    final message = (e.response?.data is Map)
        ? (e.response?.data['message']?.toString() ?? e.message)
        : e.message;
    if (status == 401) {
      return ServerException(message ?? 'Email atau kata sandi salah.');
    }
    if (status == 409) {
      return ServerException(message ?? 'Email sudah terdaftar.');
    }
    return ServerException(message ?? 'Terjadi kesalahan pada server.');
  }
}
