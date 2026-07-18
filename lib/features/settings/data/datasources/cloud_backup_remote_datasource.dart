import 'package:dio/dio.dart';
import '../../../../core/network/api_error_mapper.dart';

/// Bytes + framing metadata for one uploaded/downloaded backup body. The
/// body is always sent/received as raw (usually gzip-compressed) bytes -
/// never auto re-encoded by the HTTP layer - so compression actually saves
/// bandwidth end to end.
class BackupBytesPayload {
  final List<int> bytes;
  final String contentEncoding;
  final String contentHash;

  const BackupBytesPayload({
    required this.bytes,
    required this.contentEncoding,
    required this.contentHash,
  });
}

abstract class CloudBackupRemoteDataSource {
  /// Uploads pre-compressed bytes. [contentHash] doubles as the
  /// Idempotency-Key: a retried upload with the same hash returns the
  /// existing backup instead of creating a duplicate.
  Future<void> uploadBackup({
    required List<int> gzipBytes,
    required String contentHash,
    required String deviceId,
  });
  Future<BackupBytesPayload> downloadLatestBackup();
  Future<BackupBytesPayload> downloadBackupById(String id);
  Future<List<Map<String, dynamic>>> listBackups();
  Future<void> deleteBackup(String id);
}

class CloudBackupRemoteDataSourceImpl implements CloudBackupRemoteDataSource {
  final Dio dio;

  CloudBackupRemoteDataSourceImpl({required this.dio});

  static const _headerContentEncoding = 'X-Content-Encoding';
  static const _headerIdempotencyKey = 'Idempotency-Key';
  static const _headerDeviceId = 'X-Device-Id';

  @override
  Future<void> uploadBackup({
    required List<int> gzipBytes,
    required String contentHash,
    required String deviceId,
  }) async {
    try {
      await dio.post(
        '/backups',
        data: gzipBytes,
        options: Options(
          contentType: 'application/octet-stream',
          headers: {
            _headerContentEncoding: 'gzip',
            _headerIdempotencyKey: contentHash,
            _headerDeviceId: deviceId,
          },
        ),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<BackupBytesPayload> downloadLatestBackup() =>
      _downloadBytes('/backups/latest');

  @override
  Future<BackupBytesPayload> downloadBackupById(String id) =>
      _downloadBytes('/backups/$id');

  Future<BackupBytesPayload> _downloadBytes(String path) async {
    try {
      final response = await dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return BackupBytesPayload(
        bytes: response.data ?? const [],
        contentEncoding:
            response.headers.value(_headerContentEncoding) ?? 'identity',
        contentHash: response.headers.value(_headerIdempotencyKey) ?? '',
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listBackups() async {
    try {
      final response = await dio.get('/backups');
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> deleteBackup(String id) async {
    try {
      await dio.delete('/backups/$id');
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// 401 maps to AuthException (via the shared mapper), which the backup
  /// dispatcher relies on to tell an expired session apart from a generic
  /// failure - the two produce different BackupResultStatus values.
  Exception _mapDioException(DioException e) => mapDioException(
    e,
    codeMessages: const {
      'TOKEN_MISSING': 'Silakan masuk ke akun toko terlebih dahulu.',
      'TOKEN_INVALID': 'Silakan masuk ke akun toko terlebih dahulu.',
      'UNAUTHORIZED': 'Silakan masuk ke akun toko terlebih dahulu.',
      'PRO_REQUIRED': 'Fitur ini khusus untuk pelanggan Pro.',
      'NOT_FOUND': 'Belum ada cadangan cloud tersimpan.',
      'INVALID_BACKUP_PAYLOAD': 'Data cadangan tidak valid.',
      'CONTENT_HASH_MISMATCH': 'Data cadangan rusak saat diunggah.',
    },
    fallback: 'Gagal menghubungi server cadangan.',
  );
}
