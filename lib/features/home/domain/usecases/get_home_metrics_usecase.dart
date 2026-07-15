import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_metrics.dart';
import '../repositories/home_repository.dart';

class GetHomeMetricsUseCase {
  final HomeRepository repository;

  GetHomeMetricsUseCase(this.repository);

  Future<Either<Failure, HomeMetrics>> call({
    required bool isAdmin,
    required String? userId,
  }) async {
    return await repository.getHomeMetrics(isAdmin: isAdmin, userId: userId);
  }
}
