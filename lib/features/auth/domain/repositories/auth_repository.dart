import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String whatsapp,
  );
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCachedSession();
  Future<Either<Failure, void>> restoreFromCloud();
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
}
