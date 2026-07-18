import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';

class RegisterAccountUseCase {
  final AccountRepository repository;

  RegisterAccountUseCase(this.repository);

  Future<Either<Failure, AccountEntity>> call(
    String name,
    String email,
    String password,
    String whatsapp,
  ) async {
    return await repository.register(name, email, password, whatsapp);
  }
}

class LoginAccountUseCase {
  final AccountRepository repository;

  LoginAccountUseCase(this.repository);

  Future<Either<Failure, AccountEntity>> call(
    String email,
    String password,
  ) async {
    return await repository.login(email, password);
  }
}

class LogoutAccountUseCase {
  final AccountRepository repository;

  LogoutAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

class GetCachedAccountUseCase {
  final AccountRepository repository;

  GetCachedAccountUseCase(this.repository);

  Future<Either<Failure, AccountEntity?>> call() async {
    return await repository.getCachedAccount();
  }
}
