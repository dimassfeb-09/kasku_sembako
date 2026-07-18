import 'dart:convert';
import 'package:dio/dio.dart';
import '../error/exceptions.dart';

/// The backend's error envelope: `{"message": "...", "code": "..."}`.
///
/// [code] is the contract clients branch on. [message] is a developer/log
/// detail - it is mostly English while this UI is Indonesian, so it must not
/// be shown to users verbatim (see DESIGN.md 6.4).
class ApiError {
  final int? status;
  final String? code;
  final String? message;

  const ApiError({this.status, this.code, this.message});
}

/// Pulls the error envelope out of a [DioException] regardless of how Dio
/// decoded the body.
ApiError parseApiError(DioException e) {
  final status = e.response?.statusCode;
  final body = _decodeBody(e.response?.data);
  return ApiError(
    status: status,
    code: body?['code']?.toString(),
    message: body?['message']?.toString(),
  );
}

/// Dio's decoding depends on the response type: a JSON body arrives as a Map
/// normally, but as raw bytes when the request asked for
/// `ResponseType.bytes` (the backup download does), and as a String if the
/// content-type isn't JSON. Handle all three so error codes survive.
Map<String, dynamic>? _decodeBody(dynamic data) {
  if (data is Map) return data.cast<String, dynamic>();

  String? text;
  if (data is String) {
    text = data;
  } else if (data is List<int>) {
    try {
      text = utf8.decode(data);
    } catch (_) {
      return null;
    }
  }
  if (text == null || text.isEmpty) return null;

  try {
    final decoded = jsonDecode(text);
    return decoded is Map ? decoded.cast<String, dynamic>() : null;
  } catch (_) {
    return null;
  }
}

/// Single place that knows the backend error contract.
///
/// Resolution order for the user-facing message: the caller's Indonesian copy
/// for the server's [code], then [fallback]. The server's own `message` is
/// never surfaced - it exists for logs.
///
/// Returns [NetworkException] for transport failures, [AuthException] for 401
/// (so callers that must distinguish an expired session, like the backup
/// dispatcher, can catch it), and [ServerException] otherwise.
Exception mapDioException(
  DioException e, {
  Map<String, String> codeMessages = const {},
  String fallback = 'Terjadi kesalahan pada server.',
}) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkException('Tidak dapat terhubung ke server.');
    default:
      break;
  }

  final error = parseApiError(e);
  final message = codeMessages[error.code] ?? fallback;

  if (error.status == 401) {
    return AuthException(message);
  }
  return ServerException(message);
}
