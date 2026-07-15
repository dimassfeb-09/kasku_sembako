import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/cloud_backup_repository.dart';
import '../datasources/cloud_backup_remote_datasource.dart';

class CloudBackupRepositoryImpl implements CloudBackupRepository {
  final CloudBackupRemoteDataSource remoteDataSource;

  CloudBackupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> uploadBackup(
    Map<String, dynamic> payload,
  ) async {
    try {
      await remoteDataSource.uploadBackup(payload);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengunggah cadangan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> downloadLatestBackup() async {
    try {
      final payload = await remoteDataSource.downloadLatestBackup();
      return Right(payload);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
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
            ),
          )
          .toList();
      return Right(summaries);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal menghapus cadangan: ${e.toString()}'));
    }
  }
}
