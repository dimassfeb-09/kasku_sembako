import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(String email, String password);
  Future<UserModel> login(String email, String password);
  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({required this.dio, required this.secureStorage});

  @override
  Future<UserModel> register(String email, String password) async {
    return _authRequest('/auth/register', email, password);
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
      final userJson = response.data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      await secureStorage.write(key: AppConstants.sessionKey, value: token);
      await secureStorage.write(key: AppConstants.accountAccessTokenKey, value: token);

      return user;
    } on DioException catch (e) {
      throw _mapDioException(e);
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
