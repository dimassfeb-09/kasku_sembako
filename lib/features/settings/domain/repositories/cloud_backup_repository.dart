import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

enum UploadOutcome { uploaded, skippedUnchanged }

class CloudBackupSummary {
  final String id;
  final DateTime createdAt;
  final int sizeBytes;
  final String? deviceId;

  const CloudBackupSummary({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    this.deviceId,
  });
}

abstract class CloudBackupRepository {
  Future<Either<Failure, UploadOutcome>> uploadBackup(
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Map<String, dynamic>>> downloadLatestBackup();
  Future<Either<Failure, Map<String, dynamic>>> downloadBackupById(String id);
  Future<Either<Failure, List<CloudBackupSummary>>> listBackups();
  Future<Either<Failure, void>> deleteBackup(String id);
}
