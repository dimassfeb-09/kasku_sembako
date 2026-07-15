import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserEntity>> login(String username, String pin) async {
    try {
      final user = await localDataSource.login(username, pin);
      await localDataSource.cacheSession(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return const Left(
        DatabaseFailure('Terjadi kesalahan pada database lokal.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Gagal menghapus sesi.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedSession() async {
    try {
      final user = await localDataSource.getCachedSession();
      return Right(user);
    } catch (e) {
      return const Left(CacheFailure('Gagal mengambil sesi.'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUsers() async {
    try {
      final result = await localDataSource.hasUsers();
      return Right(result);
    } catch (e) {
      return Left(
        DatabaseFailure('Gagal memeriksa data pengguna: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerFirstAdmin(
    String username,
    String pin,
  ) async {
    try {
      final user = await localDataSource.registerFirstAdmin(username, pin);
      await localDataSource.cacheSession(user);
      return Right(user);
    } catch (e) {
      return Left(
        DatabaseFailure('Gagal mendaftarkan super admin: ${e.toString()}'),
      );
    }
  }
}
