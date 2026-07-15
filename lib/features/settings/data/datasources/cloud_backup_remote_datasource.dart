import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';

abstract class CloudBackupRemoteDataSource {
  Future<void> uploadBackup(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> downloadLatestBackup();
  Future<List<Map<String, dynamic>>> listBackups();
  Future<void> deleteBackup(String id);
}

class CloudBackupRemoteDataSourceImpl implements CloudBackupRemoteDataSource {
  final Dio dio;

  CloudBackupRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> uploadBackup(Map<String, dynamic> payload) async {
    try {
      await dio.post('/backups', data: payload);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> downloadLatestBackup() async {
    try {
      final response = await dio.get('/backups/latest');
      return response.data as Map<String, dynamic>;
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

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException('Tidak dapat terhubung ke server.');
    }
    if (e.response?.statusCode == 401) {
      return const ServerException(
        'Silakan masuk ke akun toko terlebih dahulu.',
      );
    }
    if (e.response?.statusCode == 402) {
      return const ServerException('Fitur ini khusus untuk pelanggan Pro.');
    }
    if (e.response?.statusCode == 404) {
      return const ServerException('Belum ada cadangan cloud tersimpan.');
    }
    return ServerException(e.message ?? 'Gagal menghubungi server cadangan.');
  }
}
