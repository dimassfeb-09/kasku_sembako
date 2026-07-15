import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, AccountEntity>> register(
    String email,
    String password,
  );
  Future<Either<Failure, AccountEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AccountEntity?>> getCachedAccount();
}
