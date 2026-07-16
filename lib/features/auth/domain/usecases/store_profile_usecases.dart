import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/store_profile_entity.dart';
import '../repositories/store_profile_repository.dart';

class SaveStoreProfileUseCase {
  final StoreProfileRepository repository;
  SaveStoreProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(StoreProfileEntity profile) async {
    return repository.save(profile);
  }
}

class GetStoreProfileUseCase {
  final StoreProfileRepository repository;
  GetStoreProfileUseCase(this.repository);

  Future<Either<Failure, StoreProfileEntity?>> call() async {
    return repository.get();
  }
}
