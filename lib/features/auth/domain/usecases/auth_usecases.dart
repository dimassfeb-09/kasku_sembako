import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String username, String pin) async {
    return await repository.login(username, pin);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

class GetSessionUseCase {
  final AuthRepository repository;

  GetSessionUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCachedSession();
  }
}

class HasUsersUseCase {
  final AuthRepository repository;

  HasUsersUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.hasUsers();
  }
}

class RegisterFirstAdminUseCase {
  final AuthRepository repository;

  RegisterFirstAdminUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String username, String pin) async {
    return await repository.registerFirstAdmin(username, pin);
  }
}
