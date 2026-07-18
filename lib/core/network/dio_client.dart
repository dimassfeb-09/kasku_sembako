import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

const _authEndpointPrefixes = [
  '/auth/refresh',
  '/auth/login',
  '/auth/register',
];

Dio buildDio(FlutterSecureStorage secureStorage) {
  late final Dio dio;

  // Bare Dio for the refresh call itself - it must not go through the auth
  // interceptor below, or a 401 there would try to refresh recursively.
  final refreshDio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Shared across concurrent 401s so a burst of requests that all expire
  // together triggers exactly one /auth/refresh call, not one per request.
  Future<String?>? refreshFuture;

  Future<void> clearSession() async {
    await secureStorage.delete(key: AppConstants.sessionKey);
    await secureStorage.delete(key: AppConstants.accountAccessTokenKey);
    await secureStorage.delete(key: AppConstants.accountRefreshTokenKey);
    await secureStorage.delete(key: AppConstants.accountIdKey);
    await secureStorage.delete(key: AppConstants.accountEmailKey);
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await secureStorage.read(
      key: AppConstants.accountRefreshTokenKey,
    );
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final newToken = response.data['token'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;
      await secureStorage.write(key: AppConstants.sessionKey, value: newToken);
      await secureStorage.write(
        key: AppConstants.accountAccessTokenKey,
        value: newToken,
      );
      await secureStorage.write(
        key: AppConstants.accountRefreshTokenKey,
        value: newRefreshToken,
      );
      return newToken;
    } on DioException {
      return null;
    }
  }

  dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await secureStorage.read(key: AppConstants.sessionKey) ??
            await secureStorage.read(key: AppConstants.accountAccessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final path = error.requestOptions.path;
        final isAuthEndpoint = _authEndpointPrefixes.any(path.startsWith);
        final alreadyRetried = error.requestOptions.extra['retried'] == true;

        if (error.response?.statusCode == 401 && !isAuthEndpoint) {
          if (!alreadyRetried) {
            refreshFuture ??= refreshAccessToken();
            final newToken = await refreshFuture;
            refreshFuture = null;

            if (newToken != null) {
              try {
                final retryOptions = error.requestOptions
                  ..extra = {...error.requestOptions.extra, 'retried': true}
                  ..headers = {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $newToken',
                  };
                final response = await dio.fetch(retryOptions);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
          }
          await clearSession();
        }

        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(_prettierLogInterceptor());
  }

  return dio;
}

Interceptor _prettierLogInterceptor() {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      final sb = StringBuffer()
        ..writeln('╔══ REQUEST ═══════════════════════════════════════')
        ..writeln('║  ${options.method} ${options.uri}')
        ..writeln('║')
        ..writeln('║  HEADERS')
        ..writeln('║    ${_sanitizedHeaders(options.headers)}');

      if (options.data != null) {
        final body = options.data is Map || options.data is List
            ? _pretty(options.data)
            : options.data.toString();
        sb.writeln('║');
        sb.writeln('║  BODY');
        body.split('\n').forEach((l) => sb.writeln('║  $l'));
      }
      debugPrint(sb.toString().trim());
      handler.next(options);
    },
    onResponse: (response, handler) {
      final status = response.statusCode ?? 0;
      final path = response.requestOptions.uri.path;
      final dataStr = response.data is Map || response.data is List
          ? _pretty(response.data)
          : response.data?.toString() ?? '';

      final sb = StringBuffer()
        ..writeln('╔══ RESPONSE ══════════════════════════════════════')
        ..writeln('║  ← $status ${response.statusMessage ?? ''}')
        ..writeln('║  ${response.requestOptions.method} $path');

      if (dataStr.isNotEmpty) {
        sb.writeln('║');
        sb.writeln('║  BODY');
        dataStr.split('\n').forEach((l) => sb.writeln('║  $l'));
      }
      debugPrint(sb.toString().trim());
      handler.next(response);
    },
    onError: (error, handler) {
      final method = error.requestOptions.method;
      final path = error.requestOptions.uri.path;
      final status = error.response?.statusCode ?? 0;
      final msg = error.response?.statusMessage ?? error.type.name;

      final sb = StringBuffer()
        ..writeln('╔══ ERROR ═════════════════════════════════════════')
        ..writeln('║  $status $msg')
        ..writeln('║  $method $path');

      if (error.response?.data != null) {
        final data = _pretty(error.response!.data);
        sb.writeln('║');
        sb.writeln('║  BODY');
        data.split('\n').forEach((l) => sb.writeln('║  $l'));
      }
      debugPrint(sb.toString().trim());
      handler.next(error);
    },
  );
}

String _pretty(dynamic data) {
  try {
    return const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    return data.toString();
  }
}

Map<String, dynamic> _sanitizedHeaders(Map<String, dynamic> h) {
  final s = Map<String, dynamic>.from(h);
  if (s.containsKey('Authorization')) s['Authorization'] = 'Bearer ***';
  return s;
}
