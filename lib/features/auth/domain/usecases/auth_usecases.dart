import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    return await repository.register(email, password);
  }
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    return await repository.login(email, password);
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
