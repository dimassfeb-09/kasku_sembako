import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/core/network/api_error_mapper.dart';

DioException _errorWith({
  required int status,
  dynamic data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  const codeMessages = {
    'EMAIL_TAKEN': 'Email sudah terdaftar.',
    'PRO_REQUIRED': 'Fitur ini khusus untuk pelanggan Pro.',
  };

  group('transport failures', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      test('$type maps to NetworkException', () {
        final result = mapDioException(
          DioException(requestOptions: RequestOptions(path: '/x'), type: type),
        );
        expect(result, isA<NetworkException>());
        expect(
          (result as NetworkException).message,
          'Tidak dapat terhubung ke server.',
        );
      });
    }
  });

  group('code to Indonesian message', () {
    test('known code resolves to the caller Indonesian copy', () {
      final result = mapDioException(
        _errorWith(
          status: 409,
          data: {'message': 'email already registered', 'code': 'EMAIL_TAKEN'},
        ),
        codeMessages: codeMessages,
      );
      expect(result, isA<ServerException>());
      expect((result as ServerException).message, 'Email sudah terdaftar.');
    });

    test('unknown code falls back rather than leaking the server message', () {
      final result = mapDioException(
        _errorWith(
          status: 500,
          data: {'message': 'pq: connection refused', 'code': 'INTERNAL'},
        ),
        codeMessages: codeMessages,
        fallback: 'Terjadi kesalahan pada server.',
      );
      expect(
        (result as ServerException).message,
        'Terjadi kesalahan pada server.',
      );
    });

    // DESIGN.md 6.4: user-facing copy is Indonesian, never technical/English.
    test('never surfaces the raw English server message', () {
      final result = mapDioException(
        _errorWith(
          status: 400,
          data: {'message': 'name is required', 'code': 'VALIDATION_FAILED'},
        ),
        codeMessages: codeMessages,
      );
      expect((result as ServerException).message, isNot(contains('name is required')));
    });
  });

  group('401', () {
    test('maps to AuthException so callers can detect an expired session', () {
      final result = mapDioException(
        _errorWith(
          status: 401,
          data: {'message': 'invalid or expired token', 'code': 'TOKEN_INVALID'},
        ),
        codeMessages: {'TOKEN_INVALID': 'Sesi berakhir.'},
      );
      expect(result, isA<AuthException>());
      expect((result as AuthException).message, 'Sesi berakhir.');
    });
  });

  group('body decoding', () {
    // The backup download sets responseType: bytes, so its error bodies
    // arrive as List<int> rather than a decoded Map.
    test('decodes a JSON error body delivered as raw bytes', () {
      final bytes = utf8.encode(
        jsonEncode({'message': 'no active Pro subscription', 'code': 'PRO_REQUIRED'}),
      );
      final result = mapDioException(
        _errorWith(status: 402, data: bytes),
        codeMessages: codeMessages,
      );
      expect(
        (result as ServerException).message,
        'Fitur ini khusus untuk pelanggan Pro.',
      );
    });

    test('decodes a JSON error body delivered as a String', () {
      final result = mapDioException(
        _errorWith(
          status: 409,
          data: jsonEncode({'message': 'x', 'code': 'EMAIL_TAKEN'}),
        ),
        codeMessages: codeMessages,
      );
      expect((result as ServerException).message, 'Email sudah terdaftar.');
    });

    test('falls back cleanly on a non-JSON body', () {
      final result = mapDioException(
        _errorWith(status: 500, data: '<html>502 Bad Gateway</html>'),
        codeMessages: codeMessages,
      );
      expect(result, isA<ServerException>());
      expect(
        (result as ServerException).message,
        'Terjadi kesalahan pada server.',
      );
    });

    test('falls back cleanly on a null body', () {
      final result = mapDioException(_errorWith(status: 500, data: null));
      expect(result, isA<ServerException>());
    });
  });
}
