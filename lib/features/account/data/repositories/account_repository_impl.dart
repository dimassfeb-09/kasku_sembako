import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AccountEntity>> register(
    String email,
    String password,
  ) async {
    try {
      final account = await remoteDataSource.register(email, password);
      return Right(account);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal membuat akun: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final account = await remoteDataSource.login(email, password);
      return Right(account);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal masuk: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.delete(key: AppConstants.accountAccessTokenKey);
      await secureStorage.delete(key: AppConstants.accountIdKey);
      await secureStorage.delete(key: AppConstants.accountEmailKey);
      await secureStorage.delete(key: AppConstants.accountCreatedAtKey);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Gagal keluar dari akun.'));
    }
  }

  @override
  Future<Either<Failure, AccountEntity?>> getCachedAccount() async {
    try {
      final token = await secureStorage.read(
        key: AppConstants.accountAccessTokenKey,
      );
      if (token == null) return const Right(null);

      final id = await secureStorage.read(key: AppConstants.accountIdKey);
      final email = await secureStorage.read(key: AppConstants.accountEmailKey);
      final createdAtRaw = await secureStorage.read(
        key: AppConstants.accountCreatedAtKey,
      );
      if (id == null || email == null || createdAtRaw == null) {
        return const Right(null);
      }

      return Right(
        AccountEntity(
          id: id,
          email: email,
          createdAt: DateTime.parse(createdAtRaw),
        ),
      );
    } catch (e) {
      return const Left(CacheFailure('Gagal mengambil sesi akun.'));
    }
  }
}
