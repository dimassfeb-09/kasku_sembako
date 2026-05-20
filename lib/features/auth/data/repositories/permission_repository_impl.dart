import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/permission_entity.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_local_datasource.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionLocalDataSource localDataSource;

  PermissionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, PermissionEntity?>> getUserPermission(String userId) async {
    try {
      final permission = await localDataSource.getUserPermission(userId);
      return Right(permission);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
