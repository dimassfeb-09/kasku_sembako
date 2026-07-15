import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Single Dio instance shared by every backend-facing datasource
/// (account, subscription, cloud backup). Attaches the cloud account's JWT
/// (if present) to every request and clears it on 401 so the relevant
/// bloc/cubit can react (e.g. force re-login).
class DioClient {
  static Dio build(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(
            key: AppConstants.accountAccessTokenKey,
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await secureStorage.delete(key: AppConstants.accountAccessTokenKey);
            await secureStorage.delete(key: AppConstants.accountIdKey);
            await secureStorage.delete(key: AppConstants.accountEmailKey);
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
