import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class CloudBackupSummary {
  final String id;
  final DateTime createdAt;
  final int sizeBytes;

  const CloudBackupSummary({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
  });
}

abstract class CloudBackupRepository {
  Future<Either<Failure, void>> uploadBackup(Map<String, dynamic> payload);
  Future<Either<Failure, Map<String, dynamic>>> downloadLatestBackup();
  Future<Either<Failure, List<CloudBackupSummary>>> listBackups();
  Future<Either<Failure, void>> deleteBackup(String id);
}
