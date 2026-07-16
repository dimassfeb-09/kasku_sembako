import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

Dio buildDio(FlutterSecureStorage secureStorage) {
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
          key: AppConstants.sessionKey,
        ) ?? await secureStorage.read(
          key: AppConstants.accountAccessTokenKey,
        );
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await secureStorage.delete(key: AppConstants.sessionKey);
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
