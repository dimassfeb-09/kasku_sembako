import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/store_profile_entity.dart';

abstract class StoreProfileRepository {
  Future<Either<Failure, void>> save(StoreProfileEntity profile);
  Future<Either<Failure, StoreProfileEntity?>> get();
}
