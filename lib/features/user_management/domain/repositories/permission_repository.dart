import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/permission_entity.dart';

abstract class PermissionRepository {
  Future<Either<Failure, PermissionEntity?>> getUserPermission(String userId);
}
