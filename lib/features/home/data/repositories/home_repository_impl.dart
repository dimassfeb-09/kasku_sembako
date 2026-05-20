import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_metrics.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, HomeMetrics>> getHomeMetrics({
    required bool isAdmin,
    required String? userId,
  }) async {
    try {
      final metrics = await localDataSource.getHomeMetrics(
        isAdmin: isAdmin,
        userId: userId,
      );
      return Right(metrics);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
