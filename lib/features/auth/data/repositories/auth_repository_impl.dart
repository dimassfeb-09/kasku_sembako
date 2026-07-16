import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.register(email, password);
      await secureStorage.write(key: AppConstants.currentUserIdKey, value: user.id);
      await _syncAccountSession(user);
      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal membuat akun: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await secureStorage.write(key: AppConstants.currentUserIdKey, value: user.id);
      await _syncAccountSession(user);
      return Right(user);
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
      await secureStorage.delete(key: AppConstants.sessionKey);
      await secureStorage.delete(key: AppConstants.currentUserIdKey);
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
  Future<Either<Failure, UserEntity?>> getCachedSession() async {
    try {
      final token = await secureStorage.read(key: AppConstants.sessionKey);
      if (token == null) return const Right(null);

      final user = await remoteDataSource.me();
      await secureStorage.write(key: AppConstants.currentUserIdKey, value: user.id);
      await _syncAccountSession(user);
      return Right(user);
    } on DioException {
      // Token expired or network error — treat as logged out.
      await secureStorage.delete(key: AppConstants.sessionKey);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Gagal mengambil sesi.'));
    }
  }

  Future<void> _syncAccountSession(UserEntity user) async {
    // Sync token from main auth to account keys so AccountBloc
    // finds a cached session on the subscription page.
    final token = await secureStorage.read(key: AppConstants.sessionKey);
    if (token != null) {
      await secureStorage.write(key: AppConstants.accountAccessTokenKey, value: token);
    }
    await secureStorage.write(key: AppConstants.accountIdKey, value: user.id);
    await secureStorage.write(key: AppConstants.accountEmailKey, value: user.email);
    await secureStorage.write(key: AppConstants.accountCreatedAtKey, value: DateTime.now().toIso8601String());
  }
}
