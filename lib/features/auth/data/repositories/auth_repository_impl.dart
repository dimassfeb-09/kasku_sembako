import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_json_codec.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../settings/domain/repositories/cloud_backup_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final AppDatabase database;
  final CloudBackupRepository backupRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.database,
    required this.backupRepository,
  });

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String whatsapp,
  ) async {
    try {
      final user = await remoteDataSource.register(
        name,
        email,
        password,
        whatsapp,
      );
      await secureStorage.write(
        key: AppConstants.currentUserIdKey,
        value: user.id,
      );
      await _syncAccountSession(user);
      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
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
      await secureStorage.write(
        key: AppConstants.currentUserIdKey,
        value: user.id,
      );
      await _syncAccountSession(user);
      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal masuk: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final json = await exportDbToJson(database);
      final uploadResult = await backupRepository.uploadBackup(json);
      if (uploadResult.isLeft()) {
        return const Left(
          ServerFailure('Gagal menyimpan data ke cloud. Coba lagi.'),
        );
      }

      await remoteDataSource.logout();
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Gagal menyimpan data sebelum keluar: ${e.toString()}'),
      );
    }

    try {
      await secureStorage.delete(key: AppConstants.sessionKey);
      await secureStorage.delete(key: AppConstants.currentUserIdKey);
      await secureStorage.delete(key: AppConstants.accountAccessTokenKey);
      await secureStorage.delete(key: AppConstants.accountRefreshTokenKey);
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
      await secureStorage.write(
        key: AppConstants.currentUserIdKey,
        value: user.id,
      );
      await _syncAccountSession(user);
      return Right(user);
    } on DioException {
      await secureStorage.delete(key: AppConstants.sessionKey);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Gagal mengambil sesi.'));
    }
  }

  Future<void> _syncAccountSession(UserEntity user) async {
    final token = await secureStorage.read(key: AppConstants.sessionKey);
    if (token != null) {
      await secureStorage.write(
        key: AppConstants.accountAccessTokenKey,
        value: token,
      );
    }
    await secureStorage.write(key: AppConstants.accountIdKey, value: user.id);
    await secureStorage.write(
      key: AppConstants.accountEmailKey,
      value: user.email,
    );
    await secureStorage.write(
      key: AppConstants.accountCreatedAtKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<Either<Failure, void>> restoreFromCloud() async {
    final result = await backupRepository.downloadLatestBackup();
    return result.fold(
      (failure) async {
        // No backup existing yet for this account is not an error - it's
        // simply nothing to restore (e.g. a brand-new store).
        if (failure is ServerFailure &&
            failure.message.contains('Belum ada cadangan')) {
          return const Right(null);
        }
        return Left(failure);
      },
      (payload) async {
        if (payload['tables'] == null) return const Right(null);
        try {
          await importDbFromJson(database, payload);
          return const Right(null);
        } catch (e) {
          return Left(
            DatabaseFailure('Gagal memulihkan data cadangan: ${e.toString()}'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal mengubah password: ${e.toString()}'));
    }
  }
}
