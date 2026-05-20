import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String username, String pin);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCachedSession();
  Future<Either<Failure, bool>> hasUsers();
  Future<Either<Failure, UserEntity>> registerFirstAdmin(String username, String pin);
}
