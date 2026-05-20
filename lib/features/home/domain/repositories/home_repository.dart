import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_metrics.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeMetrics>> getHomeMetrics({
    required bool isAdmin,
    required String? userId,
  });
}
