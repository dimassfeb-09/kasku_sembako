import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/store_profile_entity.dart';
import '../../domain/repositories/store_profile_repository.dart';
import '../datasources/store_profile_remote_datasource.dart';

class StoreProfileRepositoryImpl implements StoreProfileRepository {
  final StoreProfileRemoteDataSource remoteDataSource;

  StoreProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> save(StoreProfileEntity profile) async {
    try {
      await remoteDataSource.save(
        StoreProfileModel(
          ownerName: profile.ownerName,
          businessName: profile.businessName,
          businessCategory: profile.businessCategory,
          phone: profile.phone,
          address: profile.address,
        ),
      );
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal menyimpan profil toko'));
    }
  }

  @override
  Future<Either<Failure, StoreProfileEntity?>> get() async {
    try {
      final result = await remoteDataSource.get();
      if (result == null) return const Right(null);
      return Right(
        StoreProfileEntity(
          ownerName: result.ownerName,
          businessName: result.businessName,
          businessCategory: result.businessCategory,
          phone: result.phone,
          address: result.address,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat profil toko'));
    }
  }
}
