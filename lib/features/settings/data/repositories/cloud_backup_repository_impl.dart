import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/backup_payload_util.dart';
import '../../domain/repositories/cloud_backup_repository.dart';
import '../datasources/backup_schedule_local_datasource.dart';
import '../datasources/cloud_backup_remote_datasource.dart';

class CloudBackupRepositoryImpl implements CloudBackupRepository {
  final CloudBackupRemoteDataSource remoteDataSource;
  final BackupScheduleLocalDataSource localDataSource;

  CloudBackupRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UploadOutcome>> uploadBackup(
    Map<String, dynamic> payload,
  ) async {
    try {
      final compressed = BackupPayloadUtil.compress(payload);
      final lastHash = await localDataSource.readLastUploadedHash();
      if (lastHash == compressed.contentHash) {
        return const Right(UploadOutcome.skippedUnchanged);
      }

      final deviceId = await localDataSource.readOrCreateDeviceId();
      await remoteDataSource.uploadBackup(
        gzipBytes: compressed.gzipBytes,
        contentHash: compressed.contentHash,
        deviceId: deviceId,
      );
      await localDataSource.saveLastUploadedHash(compressed.contentHash);
      return const Right(UploadOutcome.uploaded);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengunggah cadangan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> downloadLatestBackup() {
    return _download(remoteDataSource.downloadLatestBackup);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> downloadBackupById(String id) {
    return _download(() => remoteDataSource.downloadBackupById(id));
  }

  Future<Either<Failure, Map<String, dynamic>>> _download(
    Future<BackupBytesPayload> Function() fetch,
  ) async {
    try {
      final raw = await fetch();
      final payload = BackupPayloadUtil.decodeBytes(
        raw.bytes,
        isGzip: raw.contentEncoding == 'gzip',
      );
      if (raw.contentHash.isNotEmpty &&
          BackupPayloadUtil.hashOf(payload) != raw.contentHash) {
        return const Left(
          ServerFailure(
            'Cadangan rusak atau tidak lengkap saat diunduh. Coba lagi.',
          ),
        );
      }
      return Right(payload);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengunduh cadangan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CloudBackupSummary>>> listBackups() async {
    try {
      final raw = await remoteDataSource.listBackups();
      final summaries = raw
          .map(
            (e) => CloudBackupSummary(
              id: e['id'] as String,
              createdAt: DateTime.parse(e['createdAt'] as String),
              sizeBytes: (e['sizeBytes'] as num).toInt(),
              deviceId: e['deviceId'] as String?,
            ),
          )
          .toList();
      return Right(summaries);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Gagal mengambil daftar cadangan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String id) async {
    try {
      await remoteDataSource.deleteBackup(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal menghapus cadangan: ${e.toString()}'));
    }
  }
}
