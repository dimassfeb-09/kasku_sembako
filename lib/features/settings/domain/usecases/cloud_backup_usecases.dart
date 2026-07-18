import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/cloud_backup_repository.dart';

class UploadCloudBackupUseCase {
  final CloudBackupRepository repository;

  UploadCloudBackupUseCase(this.repository);

  Future<Either<Failure, UploadOutcome>> call(
    Map<String, dynamic> payload,
  ) async {
    return await repository.uploadBackup(payload);
  }
}

class DownloadCloudBackupUseCase {
  final CloudBackupRepository repository;

  DownloadCloudBackupUseCase(this.repository);

  /// Returns the downloaded latest backup's JSON payload.
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.downloadLatestBackup();
  }
}

class DownloadBackupByIdUseCase {
  final CloudBackupRepository repository;

  DownloadBackupByIdUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String id) async {
    return await repository.downloadBackupById(id);
  }
}

class ListBackupsUseCase {
  final CloudBackupRepository repository;

  ListBackupsUseCase(this.repository);

  Future<Either<Failure, List<CloudBackupSummary>>> call() async {
    return await repository.listBackups();
  }
}

class DeleteBackupUseCase {
  final CloudBackupRepository repository;

  DeleteBackupUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteBackup(id);
  }
}
