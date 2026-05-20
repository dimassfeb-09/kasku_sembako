import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/permission_entity.dart';
import '../repositories/permission_repository.dart';

class GetUserPermissionUseCase {
  final PermissionRepository repository;

  GetUserPermissionUseCase(this.repository);

  Future<Either<Failure, PermissionEntity?>> call(String userId) async {
    return await repository.getUserPermission(userId);
  }
}
